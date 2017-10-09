function cell2txtWrite(arquivo,nome_arquivo)
% Esta função salva um cell array em um arquivo .txt
% Sintaxe: cell2txtWrite(arquivo,nome_arquivo)
% Entrada: 
%   arquivo - cell array de dimensão 2 que o usuário deseja salvar.
%   nome_arquivo - string contento o nome do arquivo que o usuário irá 
%   salvar. Ex: 'arquivo.txt'.
% Autor: Raymundo Machado de Azevedo Neto, raymundo.neto@usp.br
% Data de criação: 01 maio 2013
% Última modificação: --

% Verificar se arquivo é um cell array
if ~iscell(arquivo)
   error('A variável carregada deve ser da classe cell array.') 
end

if ~ischar(nome_arquivo)
   error('O nome do arquivo deve ser fornecido na classe char/string.')
end

% Criar arquivo em que o cell array será criado
aux=[]; %#ok<NASGU>
save(nome_arquivo,'aux','-ascii','-tabs')

% Abrir arquivo criado
fid=fopen(nome_arquivo,'w');

% Percorrer todas as células e salvar no arquivo de saída
for linha=1:size(arquivo,1)
    for coluna=1:size(arquivo,2)
        
        % verificar a classe do valor a ser salvo
        if isfloat(arquivo{linha,coluna})
            classe='%f';
        elseif ischar(arquivo{linha,coluna})
            classe='%s';
        else
            classe='%f';
        end
        
        % verificar se precisa pular linha
        if coluna==1 && linha~=1
            pular_linha='\n';
        else
            pular_linha=[];
        end
        
        % Separar colunas por tabulação
        tab='\t';
        
        % Imprimir valor no arquivo a ser salvo
        fprintf(fid,[pular_linha classe tab],arquivo{linha,coluna});
    end
end
fclose(fid);