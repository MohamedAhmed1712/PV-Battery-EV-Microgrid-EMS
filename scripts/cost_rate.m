function r = cost_rate(Pg, price, feedin)

    r = max(Pg, 0)*price - max(-Pg, 0)*feedin;

end