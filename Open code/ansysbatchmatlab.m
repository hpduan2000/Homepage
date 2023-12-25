% Ansys 2023 R1 based distributed computing with 24 core CPU
clear
clc
warning off

disp('Ansys batch with MATLAB')
disp('Central South Uinversity')
disp('@author: H.P.Duan; hpduan2000@csu.edu.cn')

time_total_start = datetime('now');
disp('S T A R T :');
disp(time_total_start)

disp('The work is processing...')
%%
working_path = 'path of your FEM file';  % working path *considering for-end*

ansys_path = strcat('path of ANSYS MAPDL.exe');

np = '24'; % your CPU core

jobname = strcat('FEM');

input_mac = strcat(working_path, '\', 'Main.MAC'); % Main.MAC is your FEM main file

output_file = strcat(working_path, '\', 'ans.out');

sys_char = strcat('SET KMP_STACKSIZE=2048k &',32,'"',ansys_path,'"',32,'-p ansys',32,'-np',32, np, 32,'-lch',32,'-dir',32,'"',working_path,'"',32,'-j',32,'"',jobname,'"',32,'-s read  -m 5000 -db 1000 -l en-us -b',32,'-i',32,'"',input_mac,'"',32,'-o',32,'"',output_file,'"');

anlysis = system(sys_char);

%...................................................

work_list = dir(working_path);

is_sub = [work_list.isdir];

file_list = {work_list(logical(1-is_sub)).name}';

file_ext = {'.out'; '.err'; '.SECT'; '.MAC'};

for i = 1:length(file_list)

    if ~contains(file_list{i},file_ext)

        delete([working_path,'/',file_list{i}])

    end

end
%%
disp(' ')
disp('F I N I S H E D !');
time_total_end = datetime('now');
disp(time_total_end);
disp('Cost time :');
disp(time_total_end - time_total_start);



