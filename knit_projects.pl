#!perl5

use File::Spec::Functions qw(rel2abs);
use File::Basename;
use List::Util qw(first);



$site_directory = dirname(rel2abs($0))."\\";
print $site_directory."\n";

$menu_file = $site_directory."projects_base\\project_menu.html";

@projects = qw(sn_2014 panda epub tour_forecast mobileoffice udbs minimod sn_2010 peoplemap sri_cad mom sn_2006 dmu adhd nhcei_site r180_edit gizmos frontline_site ips maxracks_site fe_site seaquest hypertv tencore sr read180 eschool lmaw fws aftts);
#@projects = qw(mobileoffice udbs minimod  sn_2014 panda epub tour_forecast);
@long_content=qw(c scripting director mac);
@strong_names = ("Maxracks","Grassroots Technologies", "Sackler Institute for Developmental Psychobiology"); 
@emp_names = ("MobileOffice", "UDBS-Plus", "Starry Night", "Math-O-Matic", "PeopleMap", "Gizmos");
@strong_names = ("RCO, Inc.", "Open Platform Group", "eSkills Learning, LLC", "Simulation Curriculum", "Imaginova", "ExploreLearning", "Scholastic, Inc.", "Sackler Institute for Developmental Psychobiology", "eSkills Learning"); 



# set up the client and skills hashes
%clients = (
 sc => ["sn_2014","tle", "sri_cad", "sn_2010"],
 scholastic => ["dmu", "r180_edit", "ips"],
 all => \@projects
 );

%archive_clients = (
 mullaghdun => ["mom"],
 sackler => ["adhd"],
 explorelearning => ["gizmos"],
imaginova => ["sn_2006"],
 sri => ["sri_cad"],
 nhcei => ["nhcei_site"],
 actv => ["hypertv","eschool"],
 maxracks => ["maxracks_site"],
 frontline => ["frontline_site"],
 feralette => ["fe_site"],
 flat => ["seaquest"],
 catharon => ["tencore"],
 eb => ["fws"],
 vtech => ["fws"], 
 terra => ["aftts"],
 cw => ["bb","tm"],
 ctw => ["lmaw","lips"],
 mazer => ["dfi"],
 cuny => ["cuny_math"]
);
%skills = (
 ios => ["mobileoffice", "minimod"],
 c => [ "sn_2014","mobileoffice", "minimod", "udbs", "dmu", "r180_edit", "sn_2010", "ips"],
 java => ["panda", "tle"],
 scripting => ["epub","minimod","sri_cad", "ips"],
 mysql => ["panda","udbs", "sri_cad", "peoplemap"],
 web => ["tour_forecast", "panda", "grd", "epub", "peoplemap"],
 );
%archive_skills = (
c => [ "sn_2014","mobileoffice", "minimod", "udbs", "dmu", "r180_edit", "sn_2006", "ips","hypertv","tencore","sr","eschool","lmaw","fws","aftts","bb","tm","lips","cuny_math"],
 director => ["mom","adhd","gizmos", "ips","seaquest","read180","aftts","dfi"],
 mac => ["sn_2010", "dmu", "r180_edit", "sn_2006", "ips","hypertv","tencore","sr","eschool","lmaw","aftts","lips","cuny_math"],
 cd => ["ips","lmaw","fws","aftts","dfi"],
 apps => ["ips","tencore","lmaw","fws","lips"],
 plugins => ["hypertv","eschool","aftts"],
 porting => ["maxracks_site","hypertv","sr","lmaw","dfi","cuny_math"],
 project_mgmt => ["sri_cad", "mom", "sn_2006","ips", "maxracks_site","hypertv"],
 production => ["sri_cad", "peoplemap","sn_2006","ips", "maxracks_site","hypertv"],
 web => ["peoplemap", "nhcei_site", "frontline_site", "maxracks_site","fe_site"],
 scripting => ["minimod", "sri_cad", "peoplemap", "sn_2006","ips", "nhcei_site","maxracks_site","fws"],
 mysql => ["udbs", "sri_cad", "peoplemap","frontline_site", "maxracks_site"],
 );

%entities = (
 xrgb => ["gizmos", "frontline_site", "maxracks_site","ips","hypertv","fe_site"],
 boing => ["fws","aftts","tm","bb", "lmaw", "maxracks_site"]
);
@indices = qw(index missing);

# do the index files
foreach $index (@indices) {
  #get the blurb
  $project_buf = getFileBuf($site_directory."index_base\\".$index."_base.html");
  
  $title=extractTitle($project_buf);
  $project_buf = stripHTMLHeader($project_buf);

  # get the page template
	 $menu_buf = getFileBuf($menu_file);
	 $menu_buf =~ s/\.\.\///g;
  #replace the ^CONTENT tag
	$menu_buf =~ s/\^CONTENT/$project_buf/;
	$menu_buf =~ s/\^TITLE/$title/;

  
  $project_file = $site_directory.$index.".html";
  open(PROJECT_FILE, ">",$project_file) || die "can't open  file '$project_file'.\n";
  print PROJECT_FILE $menu_buf;
  close PROJECT_FILE;
  if ($index =~ m/index/) {
	$project_file = $site_directory.$index.".htm";
	open(PROJECT_FILE, ">:utf8",$project_file) || die "can't open  file '$project_file'.\n";
	print PROJECT_FILE $menu_buf;
	close PROJECT_FILE;
	}
}

# do the projects
foreach $project (@projects) {
  #get the project blurb
  $project_buf = getFileBuf($site_directory."projects_base\\".$project."_base.html");
  $title=extractTitle($project_buf);
  $project_buf = stripHTMLHeader($project_buf);

  # get the page template
	 $menu_buf = getFileBuf($menu_file);

  #replace the ^CONTENT tag
		$menu_buf =~ s/\^CONTENT/$project_buf/;
	$menu_buf =~ s/\^TITLE/$title/;

  
  $project_file = $site_directory."projects\\".$project.".html";
  open(PROJECT_FILE, ">".$project_file) || die "can't open project file '$project_file'.\n";
  print PROJECT_FILE $menu_buf;
  close PROJECT_FILE;
}

#do the skills
foreach $skill (keys %skills) {
  $skill_buf = getFileBuf($site_directory."skills_base\\".$skill."_base.html");
  $title=extractTitle($skill_buf);
	
	$skill_buf = stripHTMLHeader($skill_buf);
	#print $skill_buf."\n\n";
	
	my $evenOrOdd = 0;
  foreach $project (@{$skills{$skill}}) {
    #get the project blurb
    $project_buf = tackOnProject($project, ($evenOrOdd % 2) == 0);
	
	$skill_buf = $skill_buf.$project_buf;
	
	$evenOrOdd++;
	
  }
  # get the page template
	 $menu_buf = getFileBuf($menu_file);
	
	# if this is a not long skill page, change the background color....
	
	#if( $skill =~ m/c|scripting|director|mac/ ) {
	#	print "changing'...".$skill."\n";
	# 	$menu_buf =~ s/id=\"container\"/id=\"container\" style=\"background\-color\:\#FAFAFA;\"/i;
	#	$menu_buf =~ s/id=\"body_right\"/id=\"body_right\" style=\"background\-color\:\#FCFCFC;\"/i;
	#	$menu_buf =~ s/id=\"body_left"/id=\"body_left\" style=\"border\:0;\"/i;
	#	$menu_buf =~ s/id=\"content\"/id=\"content\" style=\"border\-left\:1px solid \#C0C0C0;\"/i;
	# }
  #replace the ^CONTENT tag
		$menu_buf =~ s/\^CONTENT/$skill_buf/;
	$menu_buf =~ s/\^TITLE/$title/;

  
  $skill_file = $site_directory."skills\\".$skill.".html";
  open(SKILL_FILE, ">".$skill_file) || die "can't open skill file '$skill_file'.\n";
  print SKILL_FILE $menu_buf;
  close SKILL_FILE;
}

#do the clients
foreach $client (keys %clients) {
  $client_buf = getFileBuf($site_directory."clients_base\\".$client."_base.html");
	$title=extractTitle($client_buf);
	$client_buf = stripHTMLHeader($client_buf);
    
  my $evenOrOdd = 0;
  foreach $project (@{$clients{$client}}) {
    #get the project blurb
	$project_buf = tackOnProject($project, ($evenOrOdd % 2) == 0);
	$client_buf = $client_buf.$project_buf;   
	$evenOrOdd++;
  }

  
  # get the page template
  $menu_buf = getFileBuf($menu_file);

  #replace the ^CONTENT tag
		$menu_buf =~ s/\^CONTENT/$client_buf/;
	$menu_buf =~ s/\^TITLE/$title/;

  
  $client_file = $site_directory."clients\\".$client.".html";
  open(CLIENT_FILE, ">".$client_file) || die "can't open client file '$client_file'.\n";
  print CLIENT_FILE $menu_buf;
  close CLIENT_FILE;
}

#do the entities
#foreach $entity (keys %entities) {
#  $entity_buf = "";
#  foreach $project (@{$entities{$entity}}) {
#    #get the project blurb
#    $project_buf = getFileBuf($site_directory."projects_base\\".$project."_base.html");
#    $project_buf = stripHTMLHeader($project_buf);
#    $entity_buf = $entity_buf.$project_buf.$sep_html;
#  }

  
 # # get the page template
#	 $menu_buf = getFileBuf($menu_file);

  #replace the ^CONTENT tag
#		$menu_buf =~ s/\^CONTENT/$entity_buf/;

  
#  $entity_file = $site_directory."entities\\".$entity.".html";
#  open(ENTITY_FILE, ">".$entity_file) || die "can't open entity file '$entity_file'.\n";
#  print ENTITY_FILE $menu_buf;
#  close ENTITY_FILE;
#}

 
sub getFileBuf {
  my $the_file = shift;
  my $buf = "";

  open(THEFILE, "<:encoding(UTF-8)",$the_file) || die "can't open file '$the_file'.\n";
  read( THEFILE, $buf, 30000) || die "can't read file '$the_file'.\n";
  close(THEFILE);

  return $buf;
}

sub stripHTMLHeader {
  my $out_buf = "";
  $_ = shift;

  if (/<body>(.*)<\/body>/si) {
    $out_buf = $1; 
  }
 
  @paras = split("<p>", $out_buf);
  pop(@paras);
  $html=join("<p>",@paras);
  return join("<p>",@paras);
}

sub extractTitle {
  my $out_buf = "";
  $_ = shift;

  if (/<title>(.*)<\/title>/si) {
    $out_buf = $1; 
  }
	return $out_buf;
}
sub extractAbstract {
  my $out_buf = "";
  $_ = shift;

  if (/<body>(.*)<\/body>/si) {
    $out_buf = $1; 
  }

  return $out_buf;
}
sub extractSummary {
  my $out_buf = "";
  $_ = shift;

  if (/<body>(.*)<\/body>/si) {
    $out_buf = $1; 
  }
  
  @paras = split("<p>", $out_buf);
  if( scalar(@paras) >= 2) {
	$sum_buf=pop(@paras);
	@sum_list=split("</p>", $sum_buf);
	return shift(@sum_list);
  }else {
	return $out_buf;
	}
}
sub extractDetail {
  $_ = shift;
  my $out_buf = extractAbstract($_);
  @paras = split("<p>", $out_buf);
  if( scalar(@paras) >= 2) {
	pop(@paras);
	return join("<p>",@paras);
  }else {
	return $out_buf;
  }
}

sub tackOnProject {
	my $project= shift;
	my $evenOrOdd = shift;
	
	my $project_buf = getFileBuf($site_directory."projects_base\\".$project."_base.html");
	
	my $short_buf=extractDetail($project_buf);
	
	if( ($evenOrOdd % 2) == 0 ) {
		$short_buf = "<div class='project_cell project_cell_even'>".$short_buf;
	}
	else {
		$short_buf = "<div class='project_cell project_cell_odd'>".$short_buf;
	}

	
	return $short_buf."</div>";

#	my $out_buf = "";
#	$out_buf =$short_buf;

#	my $proj_title=extractTitle($project_buf);
#	$out_buf = "<p><h4 class=\"proj_hdr\">".$proj_title."</h4>\n";
	
#    my $index = first { $projects[$_] eq $project } 0 .. $#projects;
#	if( $index > 0 || $projects[0] eq $project) {
#		$out_buf = $out_buf." &nbsp; <a href=\"../projects/".$project.".html\">[<em>details...</em>]</a>";
#		print $project, " ", $index, "\n";
#	}
#	else {
#		print $project, " has no details\n";
#	}
#	$out_buf = $out_buf."</p>\n";
	
#	return $out_buf;
}

