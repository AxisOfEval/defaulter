require 'defaulter/version'
require 'defaulter/has_default'

ActiveRecord::Base.extend(Defaulter::HasDefault)