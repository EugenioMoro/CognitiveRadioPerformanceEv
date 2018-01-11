%this function is used to average the subcarrier interference power
%condidering only active subcarriers
function [average]=average(interference)
[E,N]=size(interference);
average=zeros(E, 1);
for e=1:E
    m=0;
    for n=1:N
        if(interference(e,n)>-inf)
            average(e,1)=average(e,1)+interference(e,n);
            m=m+1;
        end
    end
    if m>0
        average(e,1)=average(e,1)./m;
    end
end