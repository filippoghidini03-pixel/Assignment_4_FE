function phi_u = ChFuncEx3( p_plus, p_minus, mu)
    %Compute the characteristic function for a Variance-Mean process
    %IMPUTS:
    % p_plus: positive jump parameter
    % p_minus: negative jump parameter
    %OUTPUTS:
    % phi_u: characteristic function
    phi_u =  @(u) exp(1i .* mu .* u) ./ ((1 - 1i .* u ./ p_plus) .* (1 + 1i .* u ./ p_minus));
end