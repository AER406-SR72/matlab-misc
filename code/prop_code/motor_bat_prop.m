function [F] = motor_bat_prop(y,V_in,rho,K_v,K_t,D,i_0,imax,r_m,r_esc,PropData,V,options)
            %
            % this function is called by fsolve to find battery voltage
            % that satisfies battery model and motor/prop model for max
            % throttle condition (k_e = 1)
            %
            v_bat = y(1);
            %
            % with given battery voltage now solve motor/prop equations
            % find current and omega, Q etc
            % so motor torque balances prop required torque at the given
            % omega
            func = @(x) motor_prop(x,rho,K_v,K_t,D,i_0,imax,v_bat,r_m,r_esc,PropData,V);
            %
            % call matlab function fsolve to get prop/motor solution
            %
            x = fsolve(func,[7000/60*2*pi],options);
            %
            % solution for omega (that leads to motor torque and prop
            % torque being equal
            %
            omega = x(1);
            %
            % find current since we can't pass back out of motor_prop
            %
            current = (v_bat-omega/K_v)/(r_m+r_esc);
            %
            % find error in battery voltage and current from motor/prop model
            % relative to battery model
            F(1) = 100*((v_bat*current^0.05)-V_in);
end

