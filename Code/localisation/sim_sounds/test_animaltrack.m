%% weird animal tracks

startlocation = [60, 0,0];
load('animal');


 animaltrack = sim_porp_dive_track(animal, startlocation);

 plot(animaltrack.times, animaltrack.divetrack(:,end), '.-'); 
 xlabel('seconds')
