function phi_u = NMVMCharach_funct(alpha, k, sigma, nu, delta_t)
    % NMVMCharach_funct Computes the characteristic function of the log-return
    lnL= @(w) (delta_t/k).*((1-alpha)./alpha).*(1-(1+(w.*k.*sigma.^2./(1-alpha)).^(alpha)));
    phi_u = @(u) exp(-1i.*u.*lnL(nu)).*exp(lnL((u.^2+1i.*(1+2.*nu).*u)./2))
end