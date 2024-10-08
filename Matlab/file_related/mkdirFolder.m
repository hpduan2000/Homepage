% School of Civil Engineering, Central South University
% H.P.Duan, hpduan2000@csu.edu.cn
% https://www.hpduan.cn
function mkdirFolder(folder_path,folder_name,folder_n)
    if folder_n ~= 1
        for i = 1:folder_n
            name = [folder_name,'_',num2str(i)];
            mkdir([folder_path, '\', name]);
        end
    else
        name = folder_name;
        mkdir([folder_path, '\', name]);
    end
end
