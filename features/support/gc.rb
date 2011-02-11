Before do
  GC.disable
end

After do
  GC.enable
  GC.start
end
