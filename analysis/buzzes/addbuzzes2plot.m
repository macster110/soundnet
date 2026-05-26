function [h1, buzzestrk, buzzes_combined] = addbuzzes2plot(buzzes, loctracks, settings)
%ADDBUZZES2PLOT Add buzzes to a loclaisation track


% get the buzz from events
%
%[buzzes] = eventbuzzes(buzzes, eventserialID);

% match buzzes to track.
[buzzestrk, buzzes_combined] = matchbuzz2track(buzzes, loctracks, settings);

if (isempty(buzzestrk))
    h1=[];
    return;
end

%% Plot a map of locations
acmap = colormap('Jet');

% plot scatter points.
size=100;
[cols, ~] = tcolormap(60*60*24*(buzzestrk(:,1)-settings.timestart), acmap, settings.timelims(1), settings.timelims(2));
h1=scatter3(buzzestrk(:,2), buzzestrk(:,3), buzzestrk(:,4),size, cols(:, 1:3), 'd', 'filled', 'MarkerEdgeColor', 'k');


end

