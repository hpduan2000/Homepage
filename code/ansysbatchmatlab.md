# Using Matlab for ANSYS Batch processing
By H. P. Duan; hpduan2000@163.com; https://www.hpduan.cn  
Ansys 2023 R1 based distributed computing with 24 core CPU  
Input:  
working_path = '******';  
ansys_path = strcat('******');  
np = '******';  
jobname = strcat('******');  
mainMAC = '******';  
ansysbatch(working_path, ansys_path, np, jobname, mainMAC)  

## function

```matlab
function ansysbatch(working_path, nsys_path, np, jobname, mainMAC)
	%...................................................
	input_mac = strcat(working_path, '\', mainMAC);
	output_file = strcat(working_path, '\', 'ans.out');
	sys_char = strcat('SET KMP_STACKSIZE=2048k &',32,'"',...
    ansys_path,'"',32,'-p ansys',32,'-np',32, np, 32,'-lch',32,...
    '-dir',32,'"',working_path,'"',32,'-j',32,'"',jobname,'"',32,...
    '-s read  -m 5000 -db 1000 -l en-us -b',32,'-i',32,'"',...
    input_mac,'"',32,'-o',32,'"',output_file,'"');
	anlysis = system(sys_char);
	%...................................................
	work_list = dir(working_path);
	is_sub = [work_list.isdir];
	file_list = {work_list(logical(1-is_sub)).name}';
	file_ext = {'.out'; '.err'; '.SECT'; '.MAC'; '.txt'};
	for i = 1:length(file_list)
		if ~contains(file_list{i},file_ext)
			delete([working_path,'/',file_list{i}])
		end
	end
	%...................................................
end
```

