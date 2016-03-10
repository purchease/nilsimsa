# Nilsimsa hash (build 20050414)
# Ruby port (C) 2005 Martin Pirker
# released under GNU GPL V2 license
#
# inspired by Digest::Nilsimsa-0.06 from Perl CPAN and
# the original C nilsimsa-0.2.4 implementation by cmeclax
# http://ixazon.dynip.com/~cmeclax/nilsimsa.html
class Nilsimsa

  TRAN = [
    2, 214, 158, 111, 249, 29, 4, 171, 208, 34, 22, 31, 216, 115, 161, 172,
    59, 112, 98, 150, 30, 110, 143, 57, 157, 5, 20, 74, 166, 190, 174, 14,
    207, 185, 156, 154, 199, 104, 19, 225, 45, 164, 235, 81, 141, 100, 107, 80,
    35, 128, 3, 65, 236, 187, 113, 204, 122, 134, 127, 152, 242, 54, 94, 238,
    142, 206, 79, 184, 50, 182, 95, 89, 220, 27, 49, 76, 123, 240, 99, 1,
    108, 186, 7, 232, 18, 119, 73, 60, 218, 70, 254, 47, 121, 28, 155, 48,
    227, 0, 6, 126, 46, 15, 56, 51, 33, 173, 165, 84, 202, 167, 41, 252,
    90, 71, 105, 125, 197, 149, 181, 244, 11, 144, 163, 129, 109, 37, 85, 53,
    245, 117, 116, 10, 38, 191, 25, 92, 26, 198, 255, 153, 93, 132, 170, 102,
    62, 175, 120, 179, 32, 67, 193, 237, 36, 234, 230, 63, 24, 243, 160, 66,
    87, 8, 83, 96, 195, 192, 131, 64, 130, 215, 9, 189, 68, 42, 103, 168,
    147, 224, 194, 86, 159, 217, 221, 133, 21, 180, 138, 39, 40, 146, 118, 222,
    239, 248, 178, 183, 201, 61, 69, 148, 75, 17, 13, 101, 213, 52, 139, 145,
    12, 250, 135, 233, 124, 91, 177, 77, 229, 212, 203, 16, 162, 23, 137, 188,
    219, 176, 226, 151, 136, 82, 247, 72, 211, 97, 44, 58, 43, 209, 140, 251,
    241, 205, 228, 106, 231, 169, 253, 196, 55, 200, 210, 246, 223, 88, 114, 78
  ]

  POPC = [
    0, 1, 1, 2, 1, 2, 2, 3, 1, 2, 2, 3, 2, 3, 3, 4,
    1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5,
    1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5,
    2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6,
    1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5,
    2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6,
    2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6,
    3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7,
    1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5,
    2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6,
    2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6,
    3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7,
    2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5, 6,
    3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7,
    3, 4, 4, 5, 4, 5, 5, 6, 4, 5, 5, 6, 5, 6, 6, 7,
    4, 5, 5, 6, 5, 6, 6, 7, 5, 6, 6, 7, 6, 7, 7, 8
  ]

  def initialize(*data)
    @threshold=0;
    @count=0
    @acc = Array::new(256,0)
    @lastch0=@lastch1=@lastch2=@lastch3= -1

    data.each do |d| update(d) end  if data && (data.size>0)
  end

  def tran3_orig(a,b,c,n)
    (((TRAN[(a+n)&255]^TRAN[b]*(n+n+1))+TRAN[(c)^TRAN[n]])&255)
  end
  def tran3(a,b,c,n)
    ((((TRAN[(a+n)&255])^(TRAN[b])*(n+n+1))+(TRAN[(c)^(TRAN[n])]))&255)
  end

  def update(data)
    data.each_byte do |ch|
      @count +=1
      if @lastch1>-1 then
        @acc[tran3(ch,@lastch0,@lastch1,0)] +=1
      end
      if @lastch2>-1 then
        @acc[tran3(ch,@lastch0,@lastch2,1)] +=1
        @acc[tran3(ch,@lastch1,@lastch2,2)] +=1
      end
      if @lastch3>-1 then
        @acc[tran3(ch,@lastch0,@lastch3,3)] +=1
        @acc[tran3(ch,@lastch1,@lastch3,4)] +=1
        @acc[tran3(ch,@lastch2,@lastch3,5)] +=1
        @acc[tran3(@lastch3,@lastch0,ch,6)] +=1
        @acc[tran3(@lastch3,@lastch2,ch,7)] +=1
      end
      @lastch3=@lastch2
      @lastch2=@lastch1
      @lastch1=@lastch0
      @lastch0=ch
    end
  end

  def digest
    @total=0;
    case @count
      when 0..2 then ;
      when 3   then @total +=1
      when 4   then @total +=4
      else @total +=(8*@count)-28
    end
    @threshold=@total/256	

    @code=[0]*32
    (0..255).each do |i|
      offset = i>>3
      cur_val = @code[offset]
      @code[offset] = (cur_val + ( ((@acc[i]>@threshold)?(1):(0))<<(i&7) ))
#      cv = @code[i>>3]
#      if @acc[i] > @threshold
#      #@code[i>>3]+=( (((@acc[i])>@threshold)?(1):(0))<<(i&7) )
#        @code[cv] = (@code[cv] + (1 <<(i&7))).chr
#      else
#        @code[cv] = (@code[cv] + (0 <<(i&7))).chr
#      end
    end

    @code[0..31].reverse.map(&:chr).join
  end

  def hexdigest
    digest.unpack("H*")[0]
  end

  def to_s
    hexdigest
  end

  def <<(whatever)
    update(whatever)
  end

  def ==(otherdigest)
    digest == otherdigest
  end

  def file(thisone)
    File.open(thisone,"rb") do |f|
       until f.eof? do update(f.read(10480)) end
    end
  end

  def nilsimsa(otherdigest)
    bits=0; myd=digest
    (0..31).each do |i|
      bits += POPC[255&myd[i].ord^otherdigest[i].ord]
    end
    (128-bits)
  end
end

begin                               # load C core - if available
  #require "#{File.join(File.dirname(__FILE__), '..', 'ext', 'nilsimsa_native')}"
rescue LoadError => e
  # ignore lack of native module
end


