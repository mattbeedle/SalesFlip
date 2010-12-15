class String
  
  def break
    self.gsub(/\r\n/,'<br/>').html_safe if self
  end
  
end