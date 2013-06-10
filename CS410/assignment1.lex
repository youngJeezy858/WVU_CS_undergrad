	int numHouseHolds = 0;

	int tankRepairers = 0;
	int brakeMen = 0;
	int firemen = 0;
	int agent = 0;
	int carpenter = 0;
	int contractor = 0;
	int machinist = 0;
	int pipeFitter = 0;
	int salesLady = 0;
	int carRepairer = 0;
	int toolRoomClerk = 0;

%%
"head"		++numHouseHolds;
"Tank Repairer" ++tankRepairers;
"Brake man" 	++brakeMen;
"Brakeman"	++brakeMen;
"Fireman" 	++firemen;
"Agent" 	++agent;
"Carpenter"	++carpenter;
"Contractor"	++contractor;
"Machinist"	++machinist;
"Pipe Fitter"	++pipeFitter;
"Car Repairer"	++carRepairer;
"Tool Room Clerk"	++toolRoomClerk;
.
%%

main(){

  yyin = fopen("census.csv", "r");
  yylex();
  printf("1920 census Ohio Huron Willard Church Street\n");
  printf("Number of households -> %d\n", numHouseHolds);
  printf("OCCUPATIONS\n");
  printf("Number of tank repairers -> %d\n", tankRepairers);
  printf("Number of brake men -> %d\n", brakeMen);
  printf("Number of firemen -> %d\n", firemen);
  printf("Number of agents -> %d\n", agent);
  printf("Number of carpenters -> %d\n", carpenter);
  printf("Number of contractors -> %d\n", contractor);
  printf("Number of machinists -> %d\n", machinist);
  printf("Number of pipe fitters -> %d\n", pipeFitter);
  printf("Number of car repairers -> %d\n", carRepairer);
  printf("Number of tool room clerks -> %d\n", toolRoomClerk);
  printf("BIRTHPLACES (self/mother/father)\n");
  
}
