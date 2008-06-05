require 'rake'

%w(test:units test:functionals test:integration).each do |name|
  task(name).enhance do
    Asbo::tests_passed(name)
  end
end
