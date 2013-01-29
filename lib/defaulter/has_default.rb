module Defaulter
  module HasDefault
    def has_default(model, *args)
      options     = args.extract_options!

      def load_method
        @@load_method ||= (Gem::Version.new('4.0.0beta') >= Gem::Version.new(Rails.version)) ? :all : :load
      end

      has_many model.to_s.pluralize.to_sym, options do

        def default
          where(prime: true).limit(1).first
        end

        def default=(record)
          records     = self.send(load_method)

          if records.include?(record)
            ActiveRecord::Base.transaction do
              # Marking existing record as default
              records.map { |r| r.update_attribute(:prime, false) if r.prime? }
              record.update_attribute(:prime, true)
            end
          else
            raise ActiveRecord::RecordNotFound, "Record not in collection"
          end
        end

        def << (models)
          primes      = nil

          case models.class.name
          when 'Array'
            models.first.prime  = true if self.send(load_method).empty? && primes.empty? && !models.blank?
            primes              = models.select { |m| m.prime? }
            model               = models.delete(primes.last)

            ActiveRecord::Base.transaction do
              if model.blank?
                self.concat(models) unless models.blank?
              else
                models.each { |m| m.prime = false }
                self.where(prime: true).each { |r| r.update_attribute(:prime, false) }
                self.concat(models + [model])
              end
            end
          else
            unless models.blank?
              loaded       = !self.send(load_method).empty?
              models.prime = true unless loaded

              ActiveRecord::Base.transaction do
                self.where(prime: true).each { |r| r.update_attribute(:prime, false) } if loaded && models.prime?
                self.concat(models)
              end
            end
          end
        end
      end
    end
  end
end
