#===
# Init_Contener
#---
# Ecrit par Nagato Yuki
#===
module Init_Contener
  @v=[]
  module_function
  def push(mod)
    @v.push(mod) unless @v.include?(mod)
  end
  def delete(mod)
    @v.delete!(mod)
  end
  def run()
    @v.each {|mod| mod.init}
  end
end