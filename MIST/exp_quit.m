function abort=exp_quit

escape=KbName('ESCAPE');
[~,~,KeyCode]=KbCheck;
if KeyCode(escape)
    abort=1;
else
    abort=0;
end