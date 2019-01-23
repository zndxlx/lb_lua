local decipher = {}

decipher.key = 'ygp73gbu'
decipher.key_len = 8
decipher.ind = {5, 4, 7, 2, 6, 3, 8, 1}

function decipher:coltrans_decipher(input)
    local input_len = input:len()
    local base_col_len = math.modf(input_len/self.key_len)
    local base_col_remain = input_len%self.key_len
    local upto = 1
    local plaintext = {}
    
    for i = 1, self.key_len do 
        local this_col_len = base_col_len
        if  self.ind[i] <= base_col_remain then
            this_col_len = base_col_len + 1
        end
        
        local col_str = string.sub(input, upto, upto + this_col_len-1)
        
        --print ("i=", i, ",this_col_len=", this_col_len, ",col_str", col_str)
        
        for j = 1, col_str:len() do
            local index = self.ind[i]+(j-1)*self.key_len
            --print ("i=", i, ",j=", j, ",inx[i]=", self.ind[i], ",index", index, ",char", col_str:sub(j,j))
            plaintext[index] = col_str:sub(j,j)
        end
        upto = upto +this_col_len
    end

    return table.concat(plaintext)
end

function decipher:decode(input)
    local url_decode_str = ngx.unescape_uri(input)
    ngx.log(ngx.INFO, "url_decode_str:",url_decode_str)
    local coltrans_decipher_str = self:coltrans_decipher(url_decode_str)
    ngx.log(ngx.INFO, "coltrans_decipher_str:",coltrans_decipher_str)
    return ngx.decode_args(coltrans_decipher_str)
end 

return decipher
