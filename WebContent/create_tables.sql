create table users(
  id bigint primary key,
  tw_id varchar(50),
  name varchar(50),
  
  openness_adventurousness double,
  openness_artistic_interests double,
  openness_emotionality double,
  openness_imagination double,
  openness_intellect double,
  openness_authority_challenging double,
  
  conscientiousness_achievement_striving double,
  conscientiousness_cautiousness double,
  conscientiousness_dutifulness double,
  conscientiousness_orderliness double,
  conscientiousness_self_discipline double,
  conscientiousness_self_efficacy double,
  
  extraversion_activity_level double,
  extraversion_assertiveness double,
  extraversion_cheerfulness double,
  extraversion_excitement_seeking double,
  extraversion_outgoing double,
  extraversion_gregariousness double,
  
  agreeableness_altruism double,
  agreeableness_cooperation double,
  agreeableness_modesty double,
  agreeableness_uncompromising double,
  agreeableness_sympathy double,
  agreeableness_trust double,
  
  emotional_range_fiery double,
  emotional_range_prone_to_worry double,
  emotional_range_melancholy double,
  emotional_range_immoderation double,
  emotional_range_self_consciousness double,
  emotional_range_susceptible_to_stress double,
  
  updated varchar(20)
) engine=MyISAM default charset=utf8;

create table members(
  id bigint primary key,
  tw_id varchar(50),
  name varchar(50),
  
  openness_adventurousness double,
  openness_artistic_interests double,
  openness_emotionality double,
  openness_imagination double,
  openness_intellect double,
  openness_authority_challenging double,
  
  conscientiousness_achievement_striving double,
  conscientiousness_cautiousness double,
  conscientiousness_dutifulness double,
  conscientiousness_orderliness double,
  conscientiousness_self_discipline double,
  conscientiousness_self_efficacy double,
  
  extraversion_activity_level double,
  extraversion_assertiveness double,
  extraversion_cheerfulness double,
  extraversion_excitement_seeking double,
  extraversion_outgoing double,
  extraversion_gregariousness double,
  
  agreeableness_altruism double,
  agreeableness_cooperation double,
  agreeableness_modesty double,
  agreeableness_uncompromising double,
  agreeableness_sympathy double,
  agreeableness_trust double,
  
  emotional_range_fiery double,
  emotional_range_prone_to_worry double,
  emotional_range_melancholy double,
  emotional_range_immoderation double,
  emotional_range_self_consciousness double,
  emotional_range_susceptible_to_stress double,
  
  updated varchar(20),
  
  top_tw_id0 varchar(50),
  openness_tw_id0 varchar(50),
  conscientiousness_tw_id0 varchar(50),
  extraversion_tw_id0 varchar(50),
  agreeableness_tw_id0 varchar(50),
  emotional_range_tw_id0 varchar(50),
  top_tw_id1 varchar(50),
  openness_tw_id1 varchar(50),
  conscientiousness_tw_id1 varchar(50),
  extraversion_tw_id1 varchar(50),
  agreeableness_tw_id1 varchar(50),
  emotional_range_tw_id1 varchar(50)
) engine=MyISAM default charset=utf8;
