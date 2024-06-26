% Get file list from target folder
% Written by H. P. Duan; hpduan2000@csu.edu.cn; https://www.hpduan.cn  
function list = getFolderList(path)
    file = dir(path);
    list = {file.name}';
    list = list(3:end);
end