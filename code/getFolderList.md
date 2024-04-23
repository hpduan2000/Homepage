# Get file list from target folder
Written by H. P. Duan; hpduan2000@163.com; https://www.hpduan.cn  

## function
```matlab
function list = getFolderList(path)
    file = dir(path);
    list = {file.name}';
    list = list(3:end);
end
```