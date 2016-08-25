package me.juge.wpidemo;

import java.io.Serializable;

public class Member extends User implements Serializable {
	private String top_tw_id0;
	private String openness_tw_id0;
	private String conscientiousness_tw_id0;
	private String extraversion_tw_id0;
	private String agreeableness_tw_id0;
	private String emotional_range_tw_id0;
	private String top_tw_id1;
	private String openness_tw_id1;
	private String conscientiousness_tw_id1;
	private String extraversion_tw_id1;
	private String agreeableness_tw_id1;
	private String emotional_range_tw_id1;

	public Member( long id, String tw_id, String name,
			double openness_adventurousness, double openness_artistic_interests, double openness_emotionality, double openness_imagination, double openness_intellect, double openness_authority_challenging, 
			double conscientiousness_achievement_striving, double conscientiousness_cautiousness, double conscientiousness_dutifulness, double conscientiousness_orderliness, double conscientiousness_self_discipline, double conscientiousness_self_efficacy,
			double extraversion_activity_level, double extraversion_assertiveness, double extraversion_cheerfulness, double extraversion_excitement_seeking, double extraversion_outgoing, double extraversion_gregariousness,
			double agreeableness_altruism, double agreeableness_cooperation, double agreeableness_modesty, double agreeableness_uncompromising, double agreeableness_sympathy, double agreeableness_trust,
			double emotional_range_fiery, double emotional_range_prone_to_worry, double emotional_range_melancholy, double emotional_range_immoderation, double emotional_range_self_consciousness, double emotional_range_susceptible_to_stress,
			String top_tw_id0, String openness_tw_id0, String conscientiousness_tw_id0, String extraversion_tw_id0, String agreeableness_tw_id0, String emotional_range_tw_id0,
			String top_tw_id1, String openness_tw_id1, String conscientiousness_tw_id1, String extraversion_tw_id1, String agreeableness_tw_id1, String emotional_range_tw_id1,
			String updated ){
		super( id, tw_id, name,
			openness_adventurousness, openness_artistic_interests, openness_emotionality, openness_imagination, openness_intellect, openness_authority_challenging, 
			conscientiousness_achievement_striving, conscientiousness_cautiousness, conscientiousness_dutifulness, conscientiousness_orderliness, conscientiousness_self_discipline, conscientiousness_self_efficacy,
			extraversion_activity_level, extraversion_assertiveness, extraversion_cheerfulness, extraversion_excitement_seeking, extraversion_outgoing, extraversion_gregariousness,
			agreeableness_altruism, agreeableness_cooperation, agreeableness_modesty, agreeableness_uncompromising, agreeableness_sympathy, agreeableness_trust,
			emotional_range_fiery, emotional_range_prone_to_worry, emotional_range_melancholy, emotional_range_immoderation, emotional_range_self_consciousness, emotional_range_susceptible_to_stress,
			updated
		);
		
		this.top_tw_id0 = top_tw_id0;
		this.openness_tw_id0 = openness_tw_id0;
		this.conscientiousness_tw_id0 = conscientiousness_tw_id0;
		this.extraversion_tw_id0 = extraversion_tw_id0;
		this.agreeableness_tw_id0 = agreeableness_tw_id0;
		this.emotional_range_tw_id0 = emotional_range_tw_id0;
		this.top_tw_id1 = top_tw_id1;
		this.openness_tw_id1 = openness_tw_id1;
		this.conscientiousness_tw_id1 = conscientiousness_tw_id1;
		this.extraversion_tw_id1 = extraversion_tw_id1;
		this.agreeableness_tw_id1 = agreeableness_tw_id1;
		this.emotional_range_tw_id1 = emotional_range_tw_id1;
	}

	public String getOpenness_tw_id0() {
		return openness_tw_id0;
	}

	public void setOpenness_tw_id0(String openness_tw_id0) {
		this.openness_tw_id0 = openness_tw_id0;
	}

	public String getConscientiousness_tw_id0() {
		return conscientiousness_tw_id0;
	}

	public void setConscientiousness_tw_id0(String conscientiousness_tw_id0) {
		this.conscientiousness_tw_id0 = conscientiousness_tw_id0;
	}

	public String getExtraversion_tw_id0() {
		return extraversion_tw_id0;
	}

	public void setExtraversion_tw_id0(String extraversion_tw_id0) {
		this.extraversion_tw_id0 = extraversion_tw_id0;
	}

	public String getAgreeableness_tw_id0() {
		return agreeableness_tw_id0;
	}

	public void setAgreeableness_tw_id0(String agreeableness_tw_id0) {
		this.agreeableness_tw_id0 = agreeableness_tw_id0;
	}

	public String getEmotional_range_tw_id0() {
		return emotional_range_tw_id0;
	}

	public void setEmotional_range_tw_id0(String emotional_range_tw_id0) {
		this.emotional_range_tw_id0 = emotional_range_tw_id0;
	}

	public String getOpenness_tw_id1() {
		return openness_tw_id1;
	}

	public void setOpenness_tw_id1(String openness_tw_id1) {
		this.openness_tw_id1 = openness_tw_id1;
	}

	public String getConscientiousness_tw_id1() {
		return conscientiousness_tw_id1;
	}

	public void setConscientiousness_tw_id1(String conscientiousness_tw_id1) {
		this.conscientiousness_tw_id1 = conscientiousness_tw_id1;
	}

	public String getExtraversion_tw_id1() {
		return extraversion_tw_id1;
	}

	public void setExtraversion_tw_id1(String extraversion_tw_id1) {
		this.extraversion_tw_id1 = extraversion_tw_id1;
	}

	public String getAgreeableness_tw_id1() {
		return agreeableness_tw_id1;
	}

	public void setAgreeableness_tw_id1(String agreeableness_tw_id1) {
		this.agreeableness_tw_id1 = agreeableness_tw_id1;
	}

	public String getEmotional_range_tw_id1() {
		return emotional_range_tw_id1;
	}

	public void setEmotional_range_tw_id1(String emotional_range_tw_id1) {
		this.emotional_range_tw_id1 = emotional_range_tw_id1;
	}

	public String getTop_tw_id0() {
		return top_tw_id0;
	}

	public void setTop_tw_id0(String top_tw_id0) {
		this.top_tw_id0 = top_tw_id0;
	}

	public String getTop_tw_id1() {
		return top_tw_id1;
	}

	public void setTop_tw_id1(String top_tw_id1) {
		this.top_tw_id1 = top_tw_id1;
	}

}
