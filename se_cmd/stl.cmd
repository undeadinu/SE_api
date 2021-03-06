// stl.cmd

// Surface Evolver command to produce STL format text file from surface.
// Both ASCII and binary formats.
// Does only facets satisfying the "show" criterion for facets.
// Evolver command line usage:
//    read "stl.cmd"
//    stl >>> "filename.stl"
//    binary_stl >>> "filename.stl"

// Programmer: Ken Brakke, brakke@susqu.edu, http://www.susqu.edu/brakke
// Edited by Jiri Kolar
// points moved by one
/******************************************************************************************/

stl_checks := { 

  if torus then
  { errprintf "Cannot run 'stl' command in torus mode. Do 'detorus' first.\n";
    abort;
  };

  if symmetry_group then
  { errprintf "Cannot run 'stl' command in symmetry group mode. Do 'detorus' first.\n";
    abort;
  };

  if space_dimension != 3 then
  { errprintf "The 'stl' command must be run in three-dimensional space.\n";
    abort;
  };

  if surface_dimension == 1 then
  { errprintf "The 'stl' command is not meant for the string model.\n";
    abort;
  };

  if simplex_representation then
  { errprintf "The 'stl' command is not meant for the simplex model.\n";
    abort;
  };

  if lagrange_order >= 2 then
  { errprintf "The 'stl' command is meant for the linear model, not quadratic or Lagrange.\n";
    abort;
  };

} // end stl_checks

/******************************************************************************************/

/* BINARY stl
   format (from wikipedia.com), little endian:
   UINT8[80]            Header, contents not used
   UINT32               Number of triangles

   foreach triangle
     REAL32[3]           Normal vector
     REAL32[3]           Vertex 1
     REAL32[3]           Vertex 2
     REAL32[3]           Vertex 3
     UINT16              Attribute byte count
   end
*/
binary_stl := {
  local fnormal;
  define fnormal real[3];

  little_endian >> "nul";  // don't want toggle response to stl file
  // 80-byte header
  binary_printf "binary stl file, generated by Surface Evolver binary_stl command.";
  binary_printf "   padpadpadpad";
  binary_printf "%ld",sum(facet where show,1);
  foreach facet ff where show do
  { fnormal := ff.facet_normal/ff.area;
    binary_printf "%f%f%f",fnormal[1],fnormal[2],fnormal[3];
    foreach ff vertex vv do
      binary_printf "%f%f%f",vv.x+1,vv.y+1,vv.z+1;
    binary_printf "%d",0; // attribute byte count

  };
} // end binary_stl

/******************************************************************************************/

// ASCII stl

stl := {
   local mag,inx;

   stl_checks;

   printf "solid \n";
   foreach facet ff where show do
   { mag := sqrt(ff.x^2+ff.y^2+ff.z^2);
     printf "facet normal %f %f %f\n",ff.x/mag,ff.y/mag,ff.z/mag;
     printf "   outer loop\n";
     for ( inx := 1 ; inx <= 3 ; inx += 1 )
       printf "     vertex %f %f %f\n",ff.vertex[inx].x+1,ff.vertex[inx].y+1,
             ff.vertex[inx].z+1;
     printf "   endloop\n";
     printf "  endfacet\n";
   };
   printf "endsolid\n";
}

/******************************************************************************************/

// End stl.cmd

/* 
   Usage: Set the facet "show" expression for the facets you want (default is all).
   Then, for ASCII output,
      stl >>> "filename.stl"
   or for binary output, 
      binary_stl >>> "filename.stl"
*/

