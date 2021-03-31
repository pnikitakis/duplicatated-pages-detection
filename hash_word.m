% I write the hash number in a file because 
%Matlab can't read result direct from java 
function  bin_hash = hash_word(word, fid)
    zero_array = zeros(1,64);
    o = DataHasher;
    javaMethod('main', o, word);
    formatSpec = '%ld';
    fseek( fid, 0, -1);
    hash_value = fscanf(fid, formatSpec);
    bin_hash = dec2bin(typecast(uint64(hash_value),'uint64')); %??????
    bin_hash = bin_hash - '0'; %convert string to array
    
    if length(bin_hash) < 64
        zero_array(1, (64-length(bin_hash)+1):64) = bin_hash; %fill out msb with (0) if number is positive
        if bin_hash(1,1)
            zero_array(1, 1:(64-length(bin_hash))) = 1; %fill out msb with (1) if number is negative
        end
    end
    bin_hash = zero_array;
 end