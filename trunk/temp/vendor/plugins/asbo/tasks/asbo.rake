require 'rake'

Rake::Task['test:units'].enhance do
  Asbo::tests_passed('test:units')
end

Rake::Task['test:functionals'].enhance do
  Asbo::tests_passed('test:functionals')
end

Rake::Task['test:integration'].enhance do
  Asbo::tests_passed('test:integration')
end
