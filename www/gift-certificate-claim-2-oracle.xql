<?xml version="1.0"?>

<queryset>
  <rdbms>
    <type>oracle</type>
    <version>8.1.6</version>
  </rdbms>

  <fullquery name="insert_error_failed_gc_claim">      
    <querytext>
      insert into ec_problems_log
      (problem_id, problem_date, problem_details)
      values
      (ec_problem_id_sequence.nextval, sysdate,:prob_details )
    </querytext>
  </fullquery>

  <fullquery name="update_ec_cert_set_user">      
    <querytext>
      update ec_gift_certificates set user_id=:user_id, claimed_date=sysdate where gift_certificate_id=:gift_certificate_id
    </querytext>
  </fullquery>

  <fullquery name="insert_other_claim_prob">      
    <querytext>
      insert into ec_problems_log
      (problem_id, problem_date, gift_certificate_id, problem_details)
      values
      (ec_problem_id_sequence.nextval, sysdate, :gift_certificate_id, :prob_details)
    </querytext>
  </fullquery>

</queryset>
