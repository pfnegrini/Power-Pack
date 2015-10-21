//http://forum.openscad.org/staggered-honeycomb-td8242.html


//Battery type settings
lidHeight=3;
rows          = 2; 
columns       = 5; 

walls         = 2; 
height        = 50.5+1; 
connections="N";
NominalBattDiameter = 14.4;
// AA 14.4;
// D 32.5

HoleDiam = 0.02*NominalBattDiameter + NominalBattDiameter;
connSocketHeight=3;

//Choose an image for the side

//imageSide= "img/radiation-15296_640.png";
//imageSide= "img/Highvoltagesignb.png";
imageSide="img/radiation-15296_640.png";
imageTop="img/radiation-15296_640.png";

textSide="";//"10 D 12V @ 10 000mA";
textLeft=45;

textTop1="";//"10 D 12V @ 10 000mA";
textTop2="";//"NiMH charge 16h @ 1 000mAh";
textTop3="";//"TENERGY  Line 3";
text1TopLeft=45;
text2TopLeft=35;
text3TopLeft=55;

//Rendering parameters
//$fn = 50;
FN=150;

edgeRounding=2; //Useful to calculate size afer Minkowski transformation
boxX= (columns*(HoleDiam+walls))+2*walls;
boxY= ((rows-1) * (HoleDiam+walls)*(sqrt(3) / 2)+(HoleDiam+walls)+2*walls);

screwDiam = 3;
screwLenght = 10;
screwTolerance = 0.25;

//Lids
screwH=3;
screwV=2;
anchoringX=10;
anchoringY=9;



echo("Power pack dimensions excluding lids h=", height, " x=", boxX, " y=", boxY);



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
translate([(HoleDiam+walls)/2,0,1.5])cube([HoleDiam+walls, HoleDiam/4,connSocketHeight], center=true);
}

module connectionCross1(){
    rotate([0,0,55])translate([10,0,1.5])cube([HoleDiam+walls, HoleDiam/4,connSocketHeight], center=true);
}

module connectionCross2(){
    rotate([0,0,-55])translate([5,0,1.5])cube([HoleDiam+walls, HoleDiam/4,connSocketHeight], center=true);
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
    screwHoles(screwTolerance);
             translate([boxX/2,-3,height/2])rotate([90,0,0])resize([30, 30, 2])
surface(file = imageSide, center = true, invert = true);
        translate([textLeft,0,height/9]) rotate([90,0,0])  linear_extrude(height = 2)text(textSide, font = "Liberation Sans", size=4);
              

        } 

}

module batteryRack(){
           difference(){    
            
              
translate([0,0,0])SUB_outerShell(height);     

                translate([(HoleDiam/2 + walls), 
                   +(HoleDiam/2+walls)]) 
            translate([0,0,-1])SUB_honeycomb(rows, columns, HoleDiam, walls, height+2); 
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



module SUB_screwM(diam, lenght, T) {
    //Tolerance should be around 0.3
    cylinder(r = diam / 2-T, h = lenght,$fn=FN);
    translate([0, 0, -3.5]) cylinder(r = 1.15*diam, h = 3.5,$fn=FN);
}


module screwHoles(screwTolerance){
 for (j = [0: 1])
 {
    translate([0,0,0])for (i = [0: (boxX-1-3)/(screwH-1):boxX-1-3])
 {
     translate([1+i,1,+j*height+.5])rotate([j*180,0,0])SUB_screwM(2,12,screwTolerance);
      translate([1+i,-3+boxY,+j*height+.5])rotate([j*180,0,0])SUB_screwM(2,12,screwTolerance);

}

 translate([0,0,0])for (i = [1: (boxY-3/2-3)/(screwV):boxY-3/2-3])
 {
     translate([1,1*i,j*height+.5])rotate([j*180,0,0])SUB_screwM(2,12,screwTolerance);
       translate([-3+boxX,1*i,j*height+.5])rotate([j*180,0,0])SUB_screwM(2,12,screwTolerance);

}

}

}

module SUB_Lid(){
difference()
{translate([0,0,-lidHeight/2])SUB_outerShell(lidHeight);
translate([0,0,-0.4])screwHoles(-1.5*screwTolerance);
}
}


module bottomLid(){
SUB_Lid();
//translate([-anchoringX/2,0,0])rotate([0,180,0])SUB_anchor(anchoringX,anchoringY);

//translate([+boxX+anchoringX/2+edgeRounding,0,0])  rotate([0,180,0])SUB_anchor(anchoringX,anchoringY);
}

module topLid(){
    difference()
    {
        rotate([180,0,0])translate([0,-boxY,0])SUB_Lid();
     translate([boxX/4+boxX/4,boxX/8+boxY/4,lidHeight/2+0.5])rotate([0,0,0])resize([boxX/3, boxX/3, lidHeight/2])
surface(file = imageTop, center = true, invert = true);
    
        translate([text1TopLeft,boxY-boxY/6,lidHeight/2-1.5]) rotate([0,0,0])  linear_extrude(height = 2)text(textTop1, font = "Liberation Sans", size=4);
        translate([text2TopLeft,boxY-boxY/4,lidHeight/2-1.5]) rotate([0,0,0])  linear_extrude(height = 2)text(textTop2, font = "Liberation Sans", size=4);
            translate([text3TopLeft,8,lidHeight/2-1.5]) rotate([0,0,0])  linear_extrude(height = 2)text(textTop3, font = "Liberation Sans", size=3);
}
    }

module SUB_anchor(anchoringX, anchoringY){    
  difference(){
{
    cube([anchoringX,anchoringY,lidHeight], center=true);
    translate([-(anchoringX/2-4),0,0])SUB_screwM(3,16,screwTolerance);
}
}
}

//screwHoles(1*screwTolerance);
//SUB_anchor(anchoringX,anchoringY);
bottomLid();
//translate([0,0,0])topLid();
//batteryPack();
//batteryRack();
//outerShell(boxY);
//screwHoles();
//SUB_screwM(2,10,0.2);