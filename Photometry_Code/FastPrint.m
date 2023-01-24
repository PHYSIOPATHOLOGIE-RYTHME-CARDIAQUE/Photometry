function FastPrint(filename,mydir)
%mydir=cd;
if isdir(mydir)==0
mkdir(mydir)
else
end
%To DO: If current directory=figures; up one level

a= [mydir,filename];
print(gcf,'-djpeg90','-r300',a);
savefig(a)

close
