#!/usr/bin/env ruby

require "rinruby"   
RR=RinRuby.new(:echo=>false)
   n = 10
   beta_0 = 1
   beta_1 = 0.25
   alpha = 0.05
   seed = 23423
   RR.x = (1..n).entries
   RR.eval <<-EOF
     set.seed(#{seed})
     y <- #{beta_0} + #{beta_1}*x + rnorm(#{n})
     fit <- lm( y ~ x )
     est <- round(coef(fit),3)
     pvalue <- summary(fit)$coefficients[2,4]
   EOF
   puts "E(y|x) ~= #{RR.est[0]} + #{RR.est[1]} * x"
   if RR.pvalue < alpha
     puts "Reject the null hypothesis and conclude that x and y are related."
   else
     puts "There is insufficient evidence to conclude that x and y are related."
   end
