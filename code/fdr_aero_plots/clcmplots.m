CASE = "full";

mat = readmatrix(sprintf("Cl-Cm-all-defs-%s.csv", CASE));


if CASE == "full"
    labels = ["Max Deflection", "Undeflected", "+$2^\circ$ (Cruise)", "+$5^\circ$ (Climb)", "+$7^\circ$ (Stall)"];
    styles = ["-.k", ":k", "-b", "-r", "-g"];
else
    labels = ["Max Deflection", "-$0.25^\circ$ (Cruise)", "Undeflected", "+$2.5^\circ$ (Climb)", "+$4.5^\circ$ (Stall)"];
    styles = ["-.k", "-b", ":k", "-r", "-g"];
end
    

for i = 1:length(labels)
    cm = mat(:, (i-1)*3 + 1);
    cl = mat(:, (i-1)*3 + 2);

    cm = cm(cl > -0.1);
    cl = cl(cl > -0.1);

    plot(cl, cm, styles(i), "DisplayName", labels(i), "Linewidth", 1);
    hold on
end
set(gca, 'YAxisLocation', 'origin')
set(gca, 'XAxisLocation', 'origin')
xlabel("$C_L$")
ylabel("$C_M$")
legend("location", "best")
if CASE == "full"
    title("Full Cargo Load Static Longitudinal Performance")
else
    title("Empty Static Longitudinal Performance")
end
grid

exportgraphics(gcf,sprintf("clcm_%s.pdf", CASE))




