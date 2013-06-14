SimpleCov.start do
  add_filter '/test/'
  add_filter '/bin/'

  add_group 'Libraries', 'lib'
end
