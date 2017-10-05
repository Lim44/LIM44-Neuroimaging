% This script generate the five difficulty levels of arithmetic operations
% described in the original paper of the Montreal Imaging Stress Task
% https://www.ncbi.nlm.nih.gov/pmc/articles/PMC1197276/pdf/20050900s00003p319.pdf

clear all
clc

t1 = GetSecs;
% Level 1
operands1 = {'+','-'};

digits_sequences = {0:9,0:9};

count = 1;
for d = 1:size(digits_sequences,1)
    for op1 = 1:length(operands1)
        for first = digits_sequences{d,1}
            for second = digits_sequences{d,2}
                if eval([int2str(first) operands1{op1} int2str(second)]) >= 0 && eval([int2str(first) operands1{op1} int2str(second)]) < 10
                    level1{count} = [int2str(first) operands1{op1} int2str(second)];
                    count = count+1;
                end
            end
            
        end
    end
end

% Level 2
operands1 = {'+','-'};
operands2 = {'+','-'};

digits_sequences = {1:9,1:9,1:9};

count = 1;
for d = 1:size(digits_sequences,1)
    for op1 = 1:length(operands1)
        for op2 = 1:length(operands2)
            for first = digits_sequences{d,1}
                for second = digits_sequences{d,2}
                    for third = digits_sequences{d,3}
                        if eval([int2str(first) operands1{op1} int2str(second) operands1{op2} int2str(third)]) >= 0 && eval([int2str(first) operands1{op1} int2str(second) operands1{op2} int2str(third)]) < 10
                            
                            if ~(first == second && first == third)
                                level2{count,1} = [int2str(first) operands1{op1} int2str(second) operands1{op2} int2str(third)];
                                count = count+1;
                            end
                            
                        end
                    end
                    
                end
            end
        end
    end
end

% % Level 3
% operands1 = {'+','-','*'};
% operands2 = {'+','-','*'};
% 
% digits_sequences = {10:99,0:9,0:9;...
%     0:9,10:99,0:9;...
%     0:9,0:9,10:99;...
%     10:99,10:99,0:9;...
%     10:99,0:9,10:99;...
%     0:9,10:99,10:99};
% 
% count = 1;
% for d = 1:size(digits_sequences,1)
%     for op1 = 1:length(operands1)
%         for op2 = 1:length(operands2)
%             for first = digits_sequences{d,1}
%                 for second = digits_sequences{d,2}
%                     for third = digits_sequences{d,3}
%                         if eval([int2str(first) operands1{op1} int2str(second) operands1{op2} int2str(third)]) >= 0 && eval([int2str(first) operands1{op1} int2str(second) operands1{op2} int2str(third)]) < 10
%                             
%                             if isequal(operands1{op1},'*')
%                                 oper1 = 'x';
%                             else
%                                 oper1 = operands1{op1};
%                             end
%                             
%                             if isequal(operands1{op2},'*')
%                                 oper2 = 'x';
%                             else
%                                 oper2 = operands2{op2};
%                             end
%                             
%                             level3{count} = [int2str(first) oper1 int2str(second) oper2 int2str(third)];
%                             count = count+1;
%                         end
%                     end
%                     
%                 end
%             end
%         end
%     end
% end
% 
% % Level 4
% operands1 = {'+','-','*'};
% operands2 = {'+','-','*'};
% operands3 = {'+','-','*'};
% 
% digits_sequences = {10:99,0:9,0:9,0:9;...
%     0:9,10:99,0:9,0:9;...
%     0:9,0:9,10:99,0:9;...
%     0:9,0:9,0:9,10:99;...
%     10:99,10:99,0:9,0:9;...
%     10:99,0:9,10:99,0:9;...
%     10:99,0:9,0:9,10:99;...
%     0:9,10:99,10:99,0:9;...
%     0:9,10:99,0:9,10:99;...
%     0:9,0:9,10:99,10:99};
% 
% count = 1;
% for d = 1:size(digits_sequences,1)
%     for op1 = 1:length(operands1)
%         for op2 = 1:length(operands2)
%             for op3 = 1:length(operands3)
%                 for first = digits_sequences{d,1}
%                     for second = digits_sequences{d,2}
%                         for third = digits_sequences{d,3}
%                             for fourth = digits_sequences{d,4}
%                                 if eval([int2str(first) operands1{op1} int2str(second) operands1{op2} int2str(third) operands1{op3} int2str(fourth)]) >= 0 && eval([int2str(first) operands1{op1} int2str(second) operands1{op2} int2str(third) operands1{op3} int2str(fourth)]) < 10
%                                     
%                                     if isequal(operands1{op1},'*')
%                                         oper1 = 'x';
%                                     else
%                                         oper1 = operands1{op1};
%                                     end
%                                     
%                                     if isequal(operands1{op2},'*')
%                                         oper2 = 'x';
%                                     else
%                                         oper2 = operands2{op2};
%                                     end
%                                     
%                                     if isequal(operands1{op3},'*')
%                                         oper3 = 'x';
%                                     else
%                                         oper3 = operands3{op3};
%                                     end
%                                     
%                                     level4{count} = [int2str(first) oper1 int2str(second) oper2 int2str(third) oper3 int2str(fourth)];
%                                     
%                                     count = count+1;
%                                 end
%                             end
%                         end
%                     end
%                 end
%             end
%         end
%     end
% end
% 
% % Level 5
% operands1 = {'+','-','*','/'};
% operands2 = {'+','-','*','/'};
% operands3 = {'+','-','*','/'};
% 
% digits_sequences = ...
%     {10:99,0:9,0:9,0:9;...
%     0:9,10:99,0:9,0:9;...
%     0:9,0:9,10:99,0:9;...
%     0:9,0:9,0:9,10:99;...
%     10:99,10:99,0:9,0:9;...
%     10:99,0:9,10:99,0:9;...
%     10:99,0:9,0:9,10:99;...
%     0:9,10:99,10:99,0:9;...
%     0:9,10:99,0:9,10:99;...
%     0:9,0:9,10:99,10:99;...
%     10:99,10:99,10:99,0:9;...
%     10:99,10:99,0:9,10:99;...
%     10:99,0:9,10:99,10:99;...
%     0:9,10:99,10:99,10:99;...
%     10:99,10:99,10:99,10:99};
% 
% count = 1;
% for d = 1:size(digits_sequences,1)
%     for op1 = 1:length(operands1)
%         for op2 = 1:length(operands2)
%             for op3 = 1:length(operands3)
%                 for first = digits_sequences{d,1}
%                     for second = digits_sequences{d,2}
%                         for third = digits_sequences{d,3}
%                             for fourth = digits_sequences{d,4}
%                                 if eval([int2str(first) operands1{op1} int2str(second) operands1{op2} int2str(third) operands1{op3} int2str(fourth)]) >= 0 && eval([int2str(first) operands1{op1} int2str(second) operands1{op2} int2str(third) operands1{op3} int2str(fourth)]) < 10
%                                     if isequal(operands1{op1},'*')
%                                         oper1 = 'x';
%                                     else
%                                         oper1 = operands1{op1};
%                                     end
%                                     
%                                     if isequal(operands1{op2},'*')
%                                         oper2 = 'x';
%                                     else
%                                         oper2 = operands2{op2};
%                                     end
%                                     
%                                     if isequal(operands1{op3},'*')
%                                         oper3 = 'x';
%                                     else
%                                         oper3 = operands3{op3};
%                                     end
%                                     
%                                     level5{count} = [int2str(first) oper1 int2str(second) oper2 int2str(third) oper3 int2str(fourth)];
%                                     count = count+1;
%                                 end
%                             end
%                         end
%                     end
%                 end
%             end
%         end
%     end
% end

cell2txtWrite(level1,'level1.txt')
cell2txtWrite(level2,'level2.txt')
% cell2txtWrite(level3,'level3.txt')
% cell2txtWrite(level4,'level4.txt')
% cell2txtWrite(level5,'level5.txt')

arithmetic_ops.level1 = level1;
arithmetic_ops.level2 = level2;
% arithmetic_ops.level3 = level3;
% arithmetic_ops.level4 = level4;
% arithmetic_ops.level5 = level5;

save('arithmetic_ops.mat','arithmetic_ops')

t2 = GetSecs;
tempo_total = t2 - t1;
fprintf('Demorou %d horas %d minutos e %d segundos para gerar todas as operações artiméticas\n',floor(tempo_total/60/60),floor(tempo_total/60 - floor(tempo_total/60/60)*60),tempo_total - (floor(tempo_total/60)*60))
