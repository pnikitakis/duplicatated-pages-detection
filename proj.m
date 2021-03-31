clear;
tic;

fid = fopen('..\arxeio.txt', 'r+');
disp('IR project: Detecting duplicated pages');
x = input('For restaurant collection enter 0\nFor datacrawler collection enter 1\n');
if ~x
    fprintf('Reading from restaurant collection...\n');
    [~,txt,~] = xlsread('..\restaurant.csv');

%% DATA PREDEFINED
KAPPA = 3;         %maximum hamming distance similarity 
FB = 64;           %fingerprint bits
PB = 8;            %top bits of permutated fingerpint
t_num = 8;         %number of tables

table = txt;
table(1,:) = [];
table(:,1) = [];
table(:,:) = strrep(table(:,:), '"', '');
table(:,:) = strrep(table(:,:), '''', '');
table(:,:) = strrep(table(:,:), ' ', '');
table(:,:) = strrep(table(:,:), '/', '');
table(:,:) = strrep(table(:,:), '.', '');
table(:,:) = strrep(table(:,:), '-', '');

clear txt; %delete variable (txt) to free memory
            
     x = input('For 64bit hash function enter 0\nFor 32bit hash function enter 1\n');
     if  ~x
         FB = 64;
     else
         FB = 32;
     end
     
     hash_vectors = zeros(length(table),FB); %initialize table with hash values for every entry

     for i=1:length(table)
           temp = 0;
           for j=1:6
               if isempty(table{i,j})
                  table{i,j} = '0'; 
               end
               if ~x %64bits
                 hashed = hash_word(char(table{i,j}),fid); %hashing every cell and add them  
               else
                   hashed = string2hash(table{i,j});
                   if hashed < 0  %if negative we convert to positive in order to change it to binary
                       hashed = -hashed;
                       hashed = dec2bin(hashed);
                       hashed = hashed- '0';
                       if length(hashed) < 32 %if bits are less than 32, we fill with (1) because it is negative
                          temp2 = ones(1,32);
                          temp2(1,(32-length(hashed):32)) = hashed(1, :);
                          hashed = temp2;
                       end
                   else
                       hashed = dec2bin(hashed);
                       hashed = hashed- '0'; %if bits are less than 32, we fill with (0) 
                       if length(hashed) < 32 
                          temp2 = zeros(1,32);
                          temp2(1,(32-length(hashed)+1):32) = hashed(1, :);
                          hashed = temp2;
                       end
                   end
                  
                   
               end
               hashed(hashed==0) = -1; %replace (0) with (-1) we don't have weights here
               temp = temp + hashed;
           end
           hash_vectors(i,:) = temp; %hash vector for each entry 
     end

     hash_vectors(hash_vectors>0) = 1;  %if hash(i) > 0 we convert it to (1), otherwise to (0)
     hash_vectors(hash_vectors<=0) = 0;

     fingerprints = hash_vectors;
clear hash_vectors hashed table; %delete variables to free memory
 
else
    fprintf('Reading from datacrawler collection... \n');
    %% DATA PREDEFINED
KAPPA = 3;            %maximum hamming distance similarity 
FB = 64;           %fingerprint bits
PB = 8;            %top bits of permutated fingerpint
t_num = 4;

%%
    %loop for all pages
    
    %loop for the current page
    %strtok(page) 
    %lower(str);
    %porterStemmer(str)
    %hash_word(str,fid)
    %hashed(hashed==0) = -1;
    %temp = temp + hashed;
    %otan teleiwsei to loop fingerp(i,:) = temp
    
end






%% NEXT PART - GENERAL METEHOD FOR BOTH COLLECTIONS

x = input('For binary search enter 0\nFor interpolation search enter 1\n');


     
 fingerp = fingerprints(1,:); %take the 1st page to search for duplicates
 
 t_len = floor(length(fingerprints)/t_num); 

 
 temp_table = zeros(t_len, FB, t_num);
 for k=1:t_num
    temp_table(:,:, k) = fingerprints(((k-1)*t_len + 1):(k*t_len), :); %%create  tables 
    temp_table(:,:,k) = circshift(temp_table(:,:,k), [0 k*PB 0]);          %%shift right every table by PB bits
 end
 
%% SORTING

perm_table = sort(temp_table, 1, 'ascend'); 

clear temp_table; %delete variable (temp_table) to free memory

%% FIND FIRST SAME BITS


if ~x 
      
    %BINARY SEARCH
    num=0; %number of similiar fingerprints

    for k=1:t_num
        left = 0;
        right = t_len;
        perm_fingerprint = circshift(fingerp, [0 k*PB]); %the permutated fingerprint 

        while left <= right
            middle = floor((left + right)/2);


            if perm_table(middle, 1:PB, k) < perm_fingerprint(1,1:PB)
                left = middle + 1;
            elseif perm_table(middle, 1:PB, k) > perm_fingerprint(1,1:PB)
                    right = middle - 1;
            else 
                if pdist2(perm_table(middle,:,k), perm_fingerprint, 'hamming') <= KAPPA %if yes then compare whole permutated Fingerprint
                        num = num + 1;
                end

                %search under and above for the same 8 bits
                down_mid = middle - 1;
                while perm_table(down_mid, 1:PB, k) == perm_fingerprint(1,1:PB) 
                    if pdist2(perm_table(down_mid,:,k), perm_fingerprint, 'hamming') <= KAPPA 
                             num = num + 1;
                    end
                    down_mid = down_mid - 1;
                    if ~down_mid
                        break;
                    end
                end

                up_mid = middle + 1;
                while perm_table(up_mid, 1:PB, k) == perm_fingerprint(1,1:PB) 
                    if pdist2(perm_table(up_mid,:,k), perm_fingerprint, 'hamming') <= KAPPA 
                           num = num + 1;
                    end
                    up_mid = up_mid + 1;
                    if up_mid == t_len
                        break;
                    end
                end

                break; %go to the next table

            end


        end
    end

else
    
    %INTERPOLATION SEARCH
    num=0;
    similar = zeros(length(fingerprints));

      for i=1:t_num
        
            left = 1;
            right = t_len;
            perm_fingerprint = circshift(fingerp, [0 k*PB]);
           
            while left <= right
               if perm_table(left,:,k) == perm_table(right,:,k)
                        num = num + 1;      
                    break;
               end
               
               cl = (perm_fingerprint - perm_table(left,:,k)) / (perm_table(right,:,k) - perm_table(left,:,k));

               if cl < 0 || cl > 1
                   break;
               end
               
               mid = round(perm_table(left,:,k) + cl*( perm_table(right,:,k) - perm_table(left,:,k)));
               mid = sum(mid);
               if mid == 0
                   up_mid = mid + 1;
                    while perm_table(up_mid, 1:PB, k) == perm_fingerprint(1,1:PB) 
                        if pdist2(perm_table(up_mid,:,k), perm_fingerprint, 'hamming') <= KAPPA 
                            num = num + 1;
                        end
                        up_mid = up_mid + 1;
                        if up_mid == t_len
                            break;
                        end
                    end
                    break;
               end
               if perm_fingerprint(1,1:PB) < perm_table(mid,1:PB,k)
                    right = mid - 1;
               elseif perm_fingerprint(1,1:PB) > perm_table(mid,1:PB,k)
                   left = mid + 1;
               else %hit
                    if pdist2(perm_table(mid,:,k), perm_fingerprint, 'hamming') <= KAPPA %if yes then compare whole permutated Fingerprint
                        num = num + 1;
                    end

                    %search under and above for the same 8 bits
                    down_mid = mid - 1;
                    while perm_table(down_mid, 1:PB, k) == perm_fingerprint(1,1:PB) 
                        if pdist2(perm_table(down_mid,:,k), perm_fingerprint, 'hamming') <= KAPPA 
                            num = num + 1;
                        end
                        down_mid = down_mid - 1;
                        if ~down_mid
                            break;
                        end
                    end

                    up_mid = mid + 1;
                    while perm_table(up_mid, 1:PB, k) == perm_fingerprint(1,1:PB) 
                        if pdist2(perm_table(up_mid,:,k), perm_fingerprint, 'hamming') <= KAPPA 
                            num = num + 1;
                        end
                        up_mid = up_mid + 1;
                        if up_mid == t_len
                            break;
                        end
                    end

                   break;
               end

                   
            end

    
    
      end
    
    
end

num = num - 1; %exclude the same page



fprintf('\n\nResults\n\tNumber of duplicates of 1st page:\t%d\n\tNumber of tables:\t%d\n\tTop bits compared on tables:\t%d\n\tFingerprint bits:\t%d\n\n',num,t_num,PB,FB);

   



 fclose(fid);
 toc;

 
 
 
 
 




