function get_capture_from_figure()
[file,path] = uiputfile('*.jpeg');
if path~=0
    set(gcf, 'InvertHardcopy', 'off')    
    print(fullfile(path,file),gcf,'-dpng','-r300'); 
end
end