function buzzesq = filtbuzzesQ(buzzes, minq)
%Filter buzzes by their manually assigned quality

index = [];
for i=1:length(buzzes)
    switch (buzzes(i).comment)
        case 'Q1'
            q=1;
        case 'Q2'
            q=2;
        case 'Q3'
            q=3;
        otherwise
            q=Inf;
    end

    if (q<=minq)
        index = [index i];
    end
end

buzzesq=buzzes(index);

end
