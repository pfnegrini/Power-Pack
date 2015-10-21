//http://forum.openscad.org/staggered-honeycomb-td8242.html


//Battery type settings
lidHeight=3;
rows          = 3; 
columns       = 4; 

walls         = 2; 
height        = 61.5+1.5; 
NominalBattDiameter = 32.5;
// AA 14.4;

HoleDiam = 0.018*NominalBattDiameter + NominalBattDiameter;
connSocketHeight=3;

//Choose an image for the side

//imageSide= "img/radiation-15296_640.png";
//imageSide= "img/Highvoltagesignb.png";
imageSide="img/Highvoltagesignb.png";
edgeRounding=2; //Useful to calculate size afer Minkowski transformation
FN=150;



screwDiam = 3;
screwLenght = 10;
screwToleranceLock = 0.20;
screwToleranceThrough = - 0.25;

//Lids
screwH=6;
screwV=3;
anchoringX=10;
anchoringY=9;

boxX= (columns*(HoleDiam+walls))+2*walls+edgeRounding;
boxY= ((rows-1) * (HoleDiam+walls)*(sqrt(3) / 2)+(HoleDiam+walls)+4*walls);
textSide="10 D 12V @ 10 000mA";
textLeft=45;

textTop2="h=63 x=146.34 y=101.85";
textTop1=textSide;
textTopLeft=45;
//Rendering parameters
//$fn = 50;


echo("Power pack dimensions excluding lids h=", height, " x=", boxX, " y=", boxY);


module topLid(){
difference()
{translate([0,0,-lidHeight/2])SUB_outerShell(lidHeight);
translate([0,0,-boxY/2-11])rotate([0,0,0])screwHoles();
      translate([textTopLeft,boxY/2,0]) rotate([0,0,0])  linear_extrude(height = 2)text(textTop1, font = "Liberation Sans", size=4);
      translate([textTopLeft,boxY/2-20,0]) rotate([0,0,0])  linear_extrude(height = 2)text(textTop2, font = "Liberation Sans", size=4);
}
}

module SUB_screwM(diam, lenght, T) {
    //Tolerance should be around 0.3
    cylinder(r = diam / 2-T, h = lenght,$fn=FN);
    translate([0, 0, -3.5]) cylinder(r = diam + T, h = 3.5,$fn=FN);
}


module screwHoles(screwTolerance){
 for (j = [0: 1])
 {
    translate([0,0,0])for (i = [0: (boxX-1-3)/(screwH-1):boxX-1-3])
 {
     translate([1+i,1,+j*height])rotate([j*180,0,0])SUB_screwM(2,12,screwTolerance);
      translate([1+i,-3+boxY,+j*height])rotate([j*180,0,0])SUB_screwM(2,12,screwTolerance);

}

 translate([0,0,0])for (i = [1: (boxY-3/2-3)/(screwV):boxY-3/2-3])
 {
     translate([1,1*i,j*height])rotate([j*180,0,0])SUB_screwM(2,12,screwTolerance);
       translate([-3+boxX,1*i,j*height])rotate([j*180,0,0])SUB_screwM(2,12,screwTolerance);

}

}

}


module SUB_honeycomb(rows, columns, HoleDiam, walls, height) { 
    for (i = [0 : rows - 1]) { 
         { 
            for (j = [0 : (columns - 1 - i%2)]) { 
                translate([(j + (i % 2) /2) * (HoleDiam + walls), 
                           (HoleDiam + walls) * i * sqrt(3) / 2]) 
                
                difference() { 
                  //circle(r=HoleDiam/2+walls,center=true,$fn=FN); // comment out to get inverse 
                  cylinder(r=HoleDiam/2,h=height,center=false,$fn=FN);          } 

    //Add here connections
                  SUB_Conn(i,j);
                translate([0,0,height-connSocketHeight])SUB_Conn(i,j);
            }   
        } 
    } 
} 


module connectionHoriz(){
translate([(HoleDiam+walls)/2,0,1.5])cube([HoleDiam+walls, HoleDiam/6,connSocketHeight], center=true);
}

module connectionCross1(){
    rotate([0,0,55])translate([10,0,1.5])cube([HoleDiam+walls, HoleDiam/6,connSocketHeight], center=true);
}

module connectionCross2(){
    rotate([0,0,-55])translate([5,0,1.5])cube([HoleDiam+walls, HoleDiam/6,connSocketHeight], center=true);
}

module powerCableOut() {
    
    translate([NominalBattDiameter/2,NominalBattDiameter,height])rotate([0,0,-55])cube([HoleDiam+3*walls, HoleDiam/6,connSocketHeight], center=true);
    translate([NominalBattDiameter/2,3/2*NominalBattDiameter,height])rotate([0,0,0])cube([HoleDiam+3*walls, HoleDiam/6,connSocketHeight], center=true);
    
}


module SUB_outerShell(height){
     minkowski()
{
//If we use minkowsky to round edges we must reduce the box size of the cylinder radius ACTUALLY SHOULD BE THE DIAMETER boxX+2+2
               cube([boxX-2,boxY-2, height]);
                cylinder(r=2,h=0.1,$fn=FN);
}
}
module batteryPack() { 

            difference(){    
            
              
translate([0,0,0])SUB_outerShell(height);     

                translate([(HoleDiam/2 + walls), 
                   +(HoleDiam/2+walls)]) 
            translate([0,0,-1])SUB_honeycomb(rows, columns, HoleDiam, walls, height+2); 
                powerCableOut(); 
screwHoles();
             translate([boxX/2,-3,height/2])rotate([90,0,0])resize([30, 30, 2])
surface(file = imageSide, center = true, invert = true);
        translate([textLeft,0,height/9]) rotate([90,0,0])  linear_extrude(height = 2)text(textSide, font = "Liberation Sans", size=4);
              

        } 

} 

module SUB_Conn(i,j){
    
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





module bottomLid(){

translate([-anchoringX/2,0,0])  rotate([0,180,0])SUB_anchor(anchoringX,anchoringY);

translate([+boxX+anchoringX/2+edgeRounding,0,0])  rotate([0,180,0])SUB_anchor(anchoringX,anchoringY);
translate([edgeRounding,-boxY/2,0])topLid();
}


module SUB_anchor(anchoringX, anchoringY){    
  difference(){
{
    cube([anchoringX,anchoringY,lidHeight], center=true);
    translate([-(anchoringX/2-4),0,0])SUB_screwM(3,16,screwTolerance);
}
}
}

//SUB_anchor(anchoringX,anchoringY);
//bottomLid();
topLid();
//translate([edgeRounding,boxY+10,0])topLid();
//batteryPack(); 
//outerShell(boxY);
//screwHoles();
//SUB_screwM(2,10,0.2);
