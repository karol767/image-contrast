function [rdata] = rescaleCineImage(cdata)

    cdata = cdata - min(min(cdata));
    maxval = max(max(cdata));
    rdata = double(cdata)./double(maxval);
end