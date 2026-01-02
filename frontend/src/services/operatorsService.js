import { supabase } from '@/lib/supabase';

export const operatorsService = {
  async getOperators(partnerId = null, includeInactive = false) {
    let query = supabase.from('operators').select('*');

    if (partnerId) {
      query = query.eq('partner_id', partnerId);
    }

    if (!includeInactive) {
      query = query.eq('active', true);
    }

    const { data, error } = await query.order('name', { ascending: true });

    if (error) throw error;
    return data;
  },

  async getOperatorById(operatorId) {
    const { data, error } = await supabase
      .from('operators')
      .select('*')
      .eq('id', operatorId)
      .maybeSingle();

    if (error) throw error;
    return data;
  },

  async createOperator(operatorData) {
    const { data, error } = await supabase
      .from('operators')
      .insert([operatorData])
      .select()
      .single();

    if (error) throw error;
    return data;
  },

  async updateOperator(operatorId, operatorData) {
    const { data, error } = await supabase
      .from('operators')
      .update(operatorData)
      .eq('id', operatorId)
      .select()
      .single();

    if (error) throw error;
    return data;
  },

  async deleteOperator(operatorId) {
    const { error } = await supabase
      .from('operators')
      .delete()
      .eq('id', operatorId);

    if (error) throw error;
  },

  async toggleOperatorActive(operatorId, active) {
    return this.updateOperator(operatorId, { active });
  },

  async getOperatorsByPartner(partnerId) {
    return this.getOperators(partnerId, false);
  },

  async getOperatorWithSales(operatorId) {
    const { data: operatorData, error: operatorError } = await supabase
      .from('operators')
      .select('*')
      .eq('id', operatorId)
      .maybeSingle();

    if (operatorError) throw operatorError;

    const { data: salesData, error: salesError } = await supabase
      .from('sales')
      .select('*')
      .eq('operator_id', operatorId);

    if (salesError) throw salesError;

    return {
      ...operatorData,
      sales: salesData,
      salesCount: salesData.length,
    };
  },
};
