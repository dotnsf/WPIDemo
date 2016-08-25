package me.juge.wpidemo;

import java.io.Serializable;

public class User implements Serializable {
	private long id; //. id
	private String tw_id; //. screen_name http://meyou.jp/group/category/politician/
	private String name; //. name
	
	private double openness_adventurousness;
	private double openness_artistic_interests;
	private double openness_emotionality;
	private double openness_imagination;
	private double openness_intellect;
	private double openness_authority_challenging;
	private double conscientiousness_achievement_striving;
	private double conscientiousness_cautiousness;
	private double conscientiousness_dutifulness;
	private double conscientiousness_orderliness;
	private double conscientiousness_self_discipline;
	private double conscientiousness_self_efficacy;
	private double extraversion_activity_level;
	private double extraversion_assertiveness;
	private double extraversion_cheerfulness;
	private double extraversion_excitement_seeking;
	private double extraversion_outgoing;
	private double extraversion_gregariousness;
	private double agreeableness_altruism;
	private double agreeableness_cooperation;
	private double agreeableness_modesty;
	private double agreeableness_uncompromising;
	private double agreeableness_sympathy;
	private double agreeableness_trust;
	private double emotional_range_fiery;
	private double emotional_range_prone_to_worry;
	private double emotional_range_melancholy;
	private double emotional_range_immoderation;
	private double emotional_range_self_consciousness;
	private double emotional_range_susceptible_to_stress;
	
	private String updated;


	public User( long id, String tw_id, String name,
			double openness_adventurousness, double openness_artistic_interests, double openness_emotionality, double openness_imagination, double openness_intellect, double openness_authority_challenging, 
			double conscientiousness_achievement_striving, double conscientiousness_cautiousness, double conscientiousness_dutifulness, double conscientiousness_orderliness, double conscientiousness_self_discipline, double conscientiousness_self_efficacy,
			double extraversion_activity_level, double extraversion_assertiveness, double extraversion_cheerfulness, double extraversion_excitement_seeking, double extraversion_outgoing, double extraversion_gregariousness,
			double agreeableness_altruism, double agreeableness_cooperation, double agreeableness_modesty, double agreeableness_uncompromising, double agreeableness_sympathy, double agreeableness_trust,
			double emotional_range_fiery, double emotional_range_prone_to_worry, double emotional_range_melancholy, double emotional_range_immoderation, double emotional_range_self_consciousness, double emotional_range_susceptible_to_stress,
			String updated ){
		this.id = id;
		this.tw_id = tw_id;
		this.name = name;
		
		this.openness_adventurousness = openness_adventurousness;
		this.openness_artistic_interests = openness_artistic_interests;
		this.openness_emotionality = openness_emotionality;
		this.openness_imagination = openness_imagination;
		this.openness_intellect = openness_intellect;
		this.openness_authority_challenging = openness_authority_challenging;
		
		this.conscientiousness_achievement_striving = conscientiousness_achievement_striving;
		this.conscientiousness_cautiousness = conscientiousness_cautiousness;
		this.conscientiousness_dutifulness = conscientiousness_dutifulness;
		this.conscientiousness_orderliness = conscientiousness_orderliness;
		this.conscientiousness_self_discipline = conscientiousness_self_discipline;
		this.conscientiousness_self_efficacy = conscientiousness_self_efficacy;
		
		this.extraversion_activity_level = extraversion_activity_level;
		this.extraversion_assertiveness = extraversion_assertiveness;
		this.extraversion_cheerfulness = extraversion_cheerfulness;
		this.extraversion_excitement_seeking = extraversion_excitement_seeking;
		this.extraversion_outgoing = extraversion_outgoing;
		this.extraversion_gregariousness = extraversion_gregariousness;
		
		this.agreeableness_altruism = agreeableness_altruism;
		this.agreeableness_cooperation = agreeableness_cooperation;
		this.agreeableness_modesty = agreeableness_modesty;
		this.agreeableness_uncompromising = agreeableness_uncompromising;
		this.agreeableness_sympathy = agreeableness_sympathy;
		this.agreeableness_trust = agreeableness_trust;
		
		this.emotional_range_fiery = emotional_range_fiery;
		this.emotional_range_prone_to_worry = emotional_range_prone_to_worry;
		this.emotional_range_melancholy = emotional_range_melancholy;
		this.emotional_range_immoderation = emotional_range_immoderation;
		this.emotional_range_self_consciousness = emotional_range_self_consciousness;
		this.emotional_range_susceptible_to_stress = emotional_range_susceptible_to_stress;
		
		this.updated = updated;
	}


	public String getUpdated() {
		return updated;
	}


	public void setUpdated(String updated) {
		this.updated = updated;
	}


	public long getId() {
		return id;
	}


	public void setId(long id) {
		this.id = id;
	}


	public String getTw_id() {
		return tw_id;
	}


	public void setTw_id(String tw_id) {
		this.tw_id = tw_id;
	}


	public String getName() {
		return name;
	}


	public void setName(String name) {
		this.name = name;
	}


	public double getOpenness_adventurousness() {
		return openness_adventurousness;
	}


	public void setOpenness_adventurousness(double openness_adventurousness) {
		this.openness_adventurousness = openness_adventurousness;
	}


	public double getOpenness_artistic_interests() {
		return openness_artistic_interests;
	}


	public void setOpenness_artistic_interests(double openness_artistic_interests) {
		this.openness_artistic_interests = openness_artistic_interests;
	}


	public double getOpenness_emotionality() {
		return openness_emotionality;
	}


	public void setOpenness_emotionality(double openness_emotionality) {
		this.openness_emotionality = openness_emotionality;
	}


	public double getOpenness_imagination() {
		return openness_imagination;
	}


	public void setOpenness_imagination(double openness_imagination) {
		this.openness_imagination = openness_imagination;
	}


	public double getOpenness_intellect() {
		return openness_intellect;
	}


	public void setOpenness_intellect(double openness_intellect) {
		this.openness_intellect = openness_intellect;
	}


	public double getOpenness_authority_challenging() {
		return openness_authority_challenging;
	}


	public void setOpenness_authority_challenging(
			double openness_authority_challenging) {
		this.openness_authority_challenging = openness_authority_challenging;
	}


	public double getConscientiousness_achievement_striving() {
		return conscientiousness_achievement_striving;
	}


	public void setConscientiousness_achievement_striving(
			double conscientiousness_achievement_striving) {
		this.conscientiousness_achievement_striving = conscientiousness_achievement_striving;
	}


	public double getConscientiousness_cautiousness() {
		return conscientiousness_cautiousness;
	}


	public void setConscientiousness_cautiousness(
			double conscientiousness_cautiousness) {
		this.conscientiousness_cautiousness = conscientiousness_cautiousness;
	}


	public double getConscientiousness_dutifulness() {
		return conscientiousness_dutifulness;
	}


	public void setConscientiousness_dutifulness(
			double conscientiousness_dutifulness) {
		this.conscientiousness_dutifulness = conscientiousness_dutifulness;
	}


	public double getConscientiousness_orderliness() {
		return conscientiousness_orderliness;
	}


	public void setConscientiousness_orderliness(
			double conscientiousness_orderliness) {
		this.conscientiousness_orderliness = conscientiousness_orderliness;
	}


	public double getConscientiousness_self_discipline() {
		return conscientiousness_self_discipline;
	}


	public void setConscientiousness_self_discipline(
			double conscientiousness_self_discipline) {
		this.conscientiousness_self_discipline = conscientiousness_self_discipline;
	}


	public double getConscientiousness_self_efficacy() {
		return conscientiousness_self_efficacy;
	}


	public void setConscientiousness_self_efficacy(
			double conscientiousness_self_efficacy) {
		this.conscientiousness_self_efficacy = conscientiousness_self_efficacy;
	}


	public double getExtraversion_activity_level() {
		return extraversion_activity_level;
	}


	public void setExtraversion_activity_level(double extraversion_activity_level) {
		this.extraversion_activity_level = extraversion_activity_level;
	}


	public double getExtraversion_assertiveness() {
		return extraversion_assertiveness;
	}


	public void setExtraversion_assertiveness(double extraversion_assertiveness) {
		this.extraversion_assertiveness = extraversion_assertiveness;
	}


	public double getExtraversion_cheerfulness() {
		return extraversion_cheerfulness;
	}


	public void setExtraversion_cheerfulness(double extraversion_cheerfulness) {
		this.extraversion_cheerfulness = extraversion_cheerfulness;
	}


	public double getExtraversion_excitement_seeking() {
		return extraversion_excitement_seeking;
	}


	public void setExtraversion_excitement_seeking(
			double extraversion_excitement_seeking) {
		this.extraversion_excitement_seeking = extraversion_excitement_seeking;
	}


	public double getExtraversion_outgoing() {
		return extraversion_outgoing;
	}


	public void setExtraversion_outgoing(double extraversion_outgoing) {
		this.extraversion_outgoing = extraversion_outgoing;
	}


	public double getExtraversion_gregariousness() {
		return extraversion_gregariousness;
	}


	public void setExtraversion_gregariousness(double extraversion_gregariousness) {
		this.extraversion_gregariousness = extraversion_gregariousness;
	}


	public double getAgreeableness_altruism() {
		return agreeableness_altruism;
	}


	public void setAgreeableness_altruism(double agreeableness_altruism) {
		this.agreeableness_altruism = agreeableness_altruism;
	}


	public double getAgreeableness_cooperation() {
		return agreeableness_cooperation;
	}


	public void setAgreeableness_cooperation(double agreeableness_cooperation) {
		this.agreeableness_cooperation = agreeableness_cooperation;
	}


	public double getAgreeableness_modesty() {
		return agreeableness_modesty;
	}


	public void setAgreeableness_modesty(double agreeableness_modesty) {
		this.agreeableness_modesty = agreeableness_modesty;
	}


	public double getAgreeableness_uncompromising() {
		return agreeableness_uncompromising;
	}


	public void setAgreeableness_uncompromising(double agreeableness_uncompromising) {
		this.agreeableness_uncompromising = agreeableness_uncompromising;
	}


	public double getAgreeableness_sympathy() {
		return agreeableness_sympathy;
	}


	public void setAgreeableness_sympathy(double agreeableness_sympathy) {
		this.agreeableness_sympathy = agreeableness_sympathy;
	}


	public double getAgreeableness_trust() {
		return agreeableness_trust;
	}


	public void setAgreeableness_trust(double agreeableness_trust) {
		this.agreeableness_trust = agreeableness_trust;
	}


	public double getEmotional_range_fiery() {
		return emotional_range_fiery;
	}


	public void setEmotional_range_fiery(double emotional_range_fiery) {
		this.emotional_range_fiery = emotional_range_fiery;
	}


	public double getEmotional_range_prone_to_worry() {
		return emotional_range_prone_to_worry;
	}


	public void setEmotional_range_prone_to_worry(
			double emotional_range_prone_to_worry) {
		this.emotional_range_prone_to_worry = emotional_range_prone_to_worry;
	}


	public double getEmotional_range_melancholy() {
		return emotional_range_melancholy;
	}


	public void setEmotional_range_melancholy(double emotional_range_melancholy) {
		this.emotional_range_melancholy = emotional_range_melancholy;
	}


	public double getEmotional_range_immoderation() {
		return emotional_range_immoderation;
	}


	public void setEmotional_range_immoderation(double emotional_range_immoderation) {
		this.emotional_range_immoderation = emotional_range_immoderation;
	}


	public double getEmotional_range_self_consciousness() {
		return emotional_range_self_consciousness;
	}


	public void setEmotional_range_self_consciousness(
			double emotional_range_self_consciousness) {
		this.emotional_range_self_consciousness = emotional_range_self_consciousness;
	}


	public double getEmotional_range_susceptible_to_stress() {
		return emotional_range_susceptible_to_stress;
	}


	public void setEmotional_range_susceptible_to_stress(
			double emotional_range_susceptible_to_stress) {
		this.emotional_range_susceptible_to_stress = emotional_range_susceptible_to_stress;
	}

}
