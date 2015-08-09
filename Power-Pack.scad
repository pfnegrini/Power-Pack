//http://forum.openscad.org/staggered-honeycomb-td8242.html
// number of rows and columns, beware that odd rows have one cell less 
// than even rows, so the total number of cells will be about rows * (columns - 1/2) 
rows          = 3; 
columns       = 4; 

lidHeight=3;

walls         = 1; 
height        = 62+1; 
NominalBattDiameter = 33.3;

HoleDiam = 0.02*NominalBattDiameter+ NominalBattDiameter;

connSocketHeight=3;

imageSide= "img/radiation-15296_640.png";
//imageSide= "img/Highvoltagesignb.png";
//imageSide="img/high_voltage_clip_art_16682.png";


textSide="10 D 12V @ 10000mA";
//$fn = 50;
FN=50;
boxX= (columns*(HoleDiam+walls))+2*walls;
boxY= ((rows-1) * (HoleDiam+walls)*(sqrt(3) / 2)+(HoleDiam+walls)+2*walls);

screwDiam = 3;
screwLenght = 10;
screwTolerance = 0.3;
screwH=3;
screwV=2;

echo("Power pack dimensions (excluding lids h=", height, " x=", boxX, " y=", boxY);

module SUB_screwM212(tolerance) {
cylinder(r = 1.8 / 2, h = 13.2-1.2,$fn=FN);
    translate([0, 0, -1.2]) cylinder(r = 3.8/2, h = 1.2,,$fn=FN);
}

module SUB_screw(tolerance) {
    cylinder(r = screwDiam / 2 + tolerance, h = screwLenght);
    translate([0, 0, -3]) cylinder(r = 2 * screwDiam / 2 + screwTolerance, h = 4);
}


module honeycomb(rows, columns, HoleDiam, walls, height) { 
    for (i = [0 : rows - 1]) { 
         { 
            for (j = [0 : (columns - 1 - i%2)]) { 
                translate([(j + (i % 2) /2) * (HoleDiam + walls), 
                           (HoleDiam + walls) * i * sqrt(3) / 2]) 
                
                difference() { 
                  //circle(r=HoleDiam/2+walls,center=true,$fn=FN); // comment out to get inverse 
                  cylinder(r=HoleDiam/2,h=height,center=false,$fn=FN);          } 

    //Add here connections
                  Conn(i,j);
                translate([0,0,height-connSocketHeight])Conn(i,j);
            }   
        } 
    } 
} 


module connectionHoriz(){
translate([(HoleDiam+walls)/2,0,1.5])cube([HoleDiam+walls, 4,connSocketHeight], center=true);
}

module connectionCross1(){
    rotate([0,0,55])translate([10,0,1.5])cube([HoleDiam+walls, 3,connSocketHeight], center=true);
}

module connectionCross2(){
    rotate([0,0,-55])translate([5,0,1.5])cube([HoleDiam+walls, 3,connSocketHeight], center=true);
}


module outerShell(){
     minkowski()
{
//If we use minkowsky to round edges we must reduce the box size of the cylinder radius
               cube([boxX-2,boxY-2, height-1]);
                cylinder(r=2,h=1,$fn=FN);
}
}
module stack(levels) { 

            difference(){    
            
              
outerShell();     

                translate([(HoleDiam/2 + walls), 
                   +(HoleDiam/2+walls)]) 
            honeycomb(rows, columns, HoleDiam, walls, height); 
screwHoles();
             translate([boxX/2,-3,height/2])rotate([90,0,0])resize([30, 30, 2])
surface(file = imageSide, center = true, invert = true);
        translate([boxX/4+5,0,height/9]) rotate([90,0,0])  linear_extrude(height = 2)text(textSide, font = "Liberation Sans", size=4);
              

        } 

} 

module Conn(i,j){
    
  for (j = [0: (columns - 1 - i % 2)]) {
  	translate([(j + (i % 2) / 2) * (HoleDiam + walls), (HoleDiam + walls) * i * sqrt(3) / 2])

        if ((i < rows - 1) && (j < columns-1)) {
            connectionCross1();
        }

    }
     for (j = [0: (columns - 1 - i % 2)]) {
  	translate([(j + (i % 2) / 2) * (HoleDiam + walls), (HoleDiam + walls) * i * sqrt(3) / 2])

        if ((j < columns - 1) && !(i % 2) /2){
            connectionHoriz();
        }

    }
      for (j = [0: (columns - 1 - i % 2)]) {
  	translate([(j + (i % 2) / 2) * (HoleDiam + walls), (HoleDiam + walls) * i * sqrt(3) / 2])

        if ((j < columns - 1)  && (i >= 1)){
            connectionCross2();
        }

    }
    
    
}


stack(); 
//outerShell();
//screwHoles();
module screwHoles(){
 for (j = [0: 1])
 {
    for (i = [0: (boxX-1-3)/(screwH-1):boxX-1-3])
 {
     translate([1+i,1,+j*height])rotate([j*180,0,0])SUB_screwM212(0.3);
      translate([1+i,-3+boxY,+j*height])rotate([j*180,0,0])SUB_screwM212(0.3);

}

 for (i = [1: (boxY-3/2-3)/(screwV):boxY-3/2-3])
 {
     translate([1,1*i,j*height])rotate([j*180,0,0])SUB_screwM212(0.3);
       translate([-3+boxX,1*i,j*height])rotate([j*180,0,0])SUB_screwM212(0.3);

}

}

}