function res= fitness(X)
    res = 0;
        %% 初始化任务
        choose_case = 3; % 选择参数组数（1，2或者3）
        use = 1; % 任务类型(物料加工所需工序数目，1或者2)
        global mode;
        mode = "GA"; % 选择模式:"Random","GA"
        %% 初始化车间
        RGV = 1; % 初始化小车位置（1，2，3，4）
        RGV_load = 1; %两道工序专有属性（1为携带生料， 2为携带半熟品）
        RGV_num = [0, 1];
        % CNC(:, 1) 表示CNC工作状态（0为不工作，否则则为其剩余工作时间）
        % CNC(:, 2) 表示CNC处能完成的工序（1为第一道工序，2为第二道工序）
        % CNC(:, 3) 表示CNC处物料编号
        CNC = zeros(8,3);
        % 选择CNC刀具安装策略
        if choose_case == 1
            CNC(:, 2) = [1, 2, 1, 2, 1, 2, 1, 2];
        elseif choose_case == 2
            CNC(:, 2) = [1, 2, 1, 2 ,2, 2, 1, 2];
        else
            CNC(:, 2) = [1, 2, 1, 2 ,1, 1, 1, 2];
        end
        time = 0; % 时间初始化

        %% 初始化动作
        Case = zeros(3,3,3);
        Case(:, :,1) = [20, 33, 46; 560, 400, 378; 28, 31 25];
        Case(:, :,2) = [23, 41, 59; 580, 280, 500; 30, 35, 30];
        Case(:, :,3) = [18, 32, 46; 545, 455, 182; 27, 32, 25];

        %% 初始化结果
        Ans = zeros(1,6);
        num = 0;
        finished_num = 0;

        %% 模拟过程
        while time <= 28800    % 8小时等于28800分钟
            active_cnc = find(CNC(:, 1) == 0 & RGV_num(2) == CNC(:, 2) );
            active_num = length(active_cnc);
            if active_num == 0
                time = time + 1;
                CNC(:, 1) = CNC(:, 1) - ones(8,1);
                if use == 2
                    for i = 1:8
                        if CNC(i, 1) < 0
                            CNC(i, 1) = 0;
                        end
                    end
                end
                continue;
            end
            if use == 1
                [target, cost,road] = Caseone(RGV,CNC,Case(:, :,choose_case),X);
            else
                [target, cost, road] = Casetwo(RGV,RGV_num,CNC,Case(:,:,choose_case),X);
            end
            if time + cost > 28800
                break;
            end 
            % 更新CNC状态
            for i = 1 : 8
                if CNC(i, 1) > 0
                    if CNC(i, 1) > cost
                        CNC(i , 1) = CNC(i , 1) - cost;
                    else
                        CNC(i , 1) = 0;
                    end
                end
            end   
            % 一道工序的结果更新
            if use == 1
                if CNC(target , 2) < use
                    CNC(target , 2) = CNC(target , 2) + 1;
                else
                    Ans(CNC(target, 3) + 1, 3) = time;
                    CNC(target , 2) = 1;
                    finished_num = finished_num + 1;
                end
                CNC(target, 1) = Case(2, 1,choose_case);
                num = num + 1;
                CNC(target, 3) = num;
                Ans = [Ans; [target, time + road, 0,0,0,0]];
            % 两道工序的结果更新
            else
                if CNC(target , 2) == 1
                    CNC(target, 1) = Case(2, 2,choose_case);
                    Ans = [Ans; [target, time + road, 0,0,0,0]];    
                    if CNC(target, 3) ~= 0
                        RGV_num = [CNC(target, 3), 2];
                        Ans(CNC(target, 3) + 1 ,3) = time + road;
                    else
                        RGV_num = [0, 1];
                    end
                    num = num + 1;
                    CNC(target, 3) = num; 
                else
                    CNC(target, 1) = Case(2, 3,choose_case);
                    if CNC(target, 3) ~= 0
                        Ans(CNC(target, 3) + 1, 6) = time + road;
                    end
                    CNC(target, 3) = RGV_num(1);
                    RGV_num = [0, 1];
                    Ans(CNC(target, 3) + 1 ,5) = time + road;
                    Ans(CNC(target, 3) + 1, 4) = target;      
                    finished_num = finished_num + 1;
                end
            end
            % 更新小车位置
            RGV = ceil(2 \ target);
            % 更新时间
            time = time + cost;
        end
        Ans(1, :) = [];
        if use == 1
            Ans = Ans(:,1:3);
        end
        res = res + finished_num;
end

%% Case1 ： 一道工序
function  [target, cost,road] = Caseone(RGV,CNC,Case,X)
    global mode;
    active_cnc = find(CNC(:, 1) == 0);
    if mode == "Random"
        target = Random(active_cnc);
    elseif mode == "GA"
        target = GA_one(active_cnc, RGV,X);
    end
    road = abs(ceil(2 \ target) - RGV);
    if road == 0
        cost = 0;
    else
        cost = Case(1, road);
        road = cost;
    end
    if mod(target, 2) == 0
        cost  = cost + Case(3,2);
    else
        cost = cost + Case(3,1);
    end
    if CNC(target, 2) ~= 0
        cost  = cost + Case(3, 3);
    end
end
%% 函数
function target = GA_one(active_cnc, RGV,X)
    temp = 0;
    active_num = length(active_cnc);
    for i = 1 : active_num
        temp = temp +  power(2 , 8 - active_cnc(i));
    end
    temp = temp +  256 * (RGV - 1);
    target = X(temp);
end

%% Case2 ： 两道工序
function  [target, cost, road] = Casetwo(RGV,RGV_num,CNC,Case,X)
    global mode;
    active_cnc = find(CNC(:, 1) == 0 & RGV_num(2) == CNC(:, 2) );
    if mode == "Random"
        target = Random(active_cnc);
    elseif mode == "GA"
        target = GA_two(active_cnc, RGV, X);
    end
    target = Random(active_cnc);
    road_length = abs(ceil(2 \ target) - RGV);
    if  road_length == 0
        road = 0;
    else
        road = Case(1, road_length);
    end
    if mod(target, 2) == 0
        cost  = road + Case(3,2);
    else
        cost = road + Case(3,1);
    end
end

%% 函数
function target = GA_two(active_cnc, RGV,X)
    temp = 0;
    active_num = length(active_cnc);
    for i = 1 : active_num
        temp = temp +  power(2 , 8 - active_cnc(i));
    end
    temp = temp +  256 * (RGV - 1);
    target = X(temp);
end
