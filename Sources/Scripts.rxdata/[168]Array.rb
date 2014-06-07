#===
# Array
#---
# Ecrit par Nagato Yuki
#===

class Array
  def count(object)
    cnt=0
    size.times do |i| 
      cnt+=1 if self[i]==object
    end
    return cnt
  end
end