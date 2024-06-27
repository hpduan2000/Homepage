% Using Matlab for ANSYS Batch processing
% Written by H. P. Duan; hpduan2000@csu.edu.cn; https://www.hpduan.cn  
function editTextInLine(path,filename,lineNum,editString,desireString)
    filepath = [path, '\', filename];
    fid = fopen(filepath,'r');
        i = 0;
        content = {};
        while ~feof(fid)
            tline = fgetl(fid);
            i = i+1;
            content{end+1} = tline;
        end    
    fclose(fid);
    content{lineNum} = strrep(content{lineNum}, editString, desireString);
    fid = fopen(filepath,'w');
        for k = 1: 1: size(content,2)
            fprintf(fid,'%s\n',content{k});
        end    
    fclose(fid);
end