I = imread("low_light_1.jpg");
%imshow(I)
I = im2double(I);
result = zeros(size(I,1),size(I,2),size(I,3));


R = 255 - I;

A = find_A(R);

for row = 1:size(I,1)
    for col = 1:size(I,2)
        t = find_t(R,A,row,col);
        if t <0.5
            t = 2*t;
        end
        result(row,col,:) = (R(row,col,:) - A)./ t + A;
    end
end
imwrite(result,"result.png")






function t = find_t(R,A,row,col)
    if row > 4  
        row_s = row-4;
    else
        row_s = 1;
        row_e = 9;

    end
    if row < (size(R,1)-3)
        
        row_e = row+4;
    else
        row_e = size(R,1)
        row_s = size(R,1)-8
    
    end


    if col > 4  
        col_s = col-4;
    else
        col_s = 1;
        col_e = 9;

    end
    if col < (size(R,2)-3)
        
        col_e = col+4;
    else
        col_e = size(R,2)
        col_s = size(R,2)-8
    
    end
    omega = R(row_s:row_e,col_s:col_e,:);
    t = min(min(double(1 - 0.8 * omega./A)));
end

function A = find_A(R)
    pixel_array = zeros(1, size(R,1) * size(R,2) * size(R,3));
    A = 0;
    count = 1;
    for row = 1:size(R,1)
        for col = 1:size(R,2)
            min_intensity = R(row,col,1);
            if min_intensity < R(row,col,2)
                min_intensity = R(row,col,2);
            end
            if min_intensity < R(row,col,3)
                min_intensity = R(row,col,3);
            end
            pixel_array(count) = min_intensity;
            count = count + 1;

        end
    end
    [sorted_pixel,sort_inx] = sort(pixel_array,'descend');
    sum = 0;
    for pixel = 1:100
        row = floor(sort_inx(pixel)/size(R,2));
        
        col = mod(sort_inx(pixel),size(R,2));
        if row == 0
            row = 1;
        end
        if col == 0
            col = 1;
        end
        temp_sum = R(row,col,1) + R(row,col,2) + R(row,col,3);
        if temp_sum > sum
            sum = temp_sum;
            row_max = row;
            col_max = col;
        end
    end
    A = R(row_max,col_max,:);

end