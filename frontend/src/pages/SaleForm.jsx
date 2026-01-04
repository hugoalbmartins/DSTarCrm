import { useState, useEffect } from "react";
import { useAuth } from "@/App";
import { useNavigate, useSearchParams } from "react-router-dom";
import { salesService } from "@/services/salesService";
import { partnersService } from "@/services/partnersService";
import { operatorsService } from "@/services/operatorsService";
import { usersService } from "@/services/usersService";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Checkbox } from "@/components/ui/checkbox";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog";
import { toast } from "sonner";
import { ArrowLeft, Save, Loader2, User, FileText, Zap, Phone as PhoneIcon, ArrowRight, Home, Plus } from "lucide-react";

const CATEGORIES = [
  { value: "energia", label: "Energia" },
  { value: "telecomunicacoes", label: "Telecomunicações" },
  { value: "paineis_solares", label: "Painéis Solares" }
];

const SALE_TYPES = [
  { value: "nova_instalacao", label: "Nova Instalação (NI)" },
  { value: "refid", label: "Refid (Renovação)" },
  { value: "mudanca_casa", label: "Mudança de Casa (MC)" }
];

const ENERGY_TYPES = [
  { value: "eletricidade", label: "Eletricidade" },
  { value: "gas", label: "Gás" },
  { value: "dual", label: "Dual (Eletricidade + Gás)" }
];

const ENERGY_TYPE_MAP = {
  eletricidade: "Eletricidade",
  gas: "Gás",
  dual: "Dual (Eletricidade + Gás)"
};

const POTENCIAS = [
  "1.15", "2.3", "3.45", "4.6", "5.75", "6.9", "10.35", "13.8", 
  "17.25", "20.7", "27.6", "34.5", "41.4", "Outra"
];

const ESCALOES_GAS = [
  "Escalão 1", "Escalão 2", "Escalão 3", "Escalão 4"
];

export default function SaleForm() {
  const { user } = useAuth();
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();

  const [loading, setLoading] = useState(false);
  const [partners, setPartners] = useState([]);
  const [sellers, setSellers] = useState([]);
  const [operators, setOperators] = useState([]);
  const [loadingPartners, setLoadingPartners] = useState(true);
  const [loadingOperators, setLoadingOperators] = useState(false);
  const [loadingRefidData, setLoadingRefidData] = useState(false);
  const [originalAddress, setOriginalAddress] = useState(null);
  const [showAddressChangeDialog, setShowAddressChangeDialog] = useState(false);

  const [nifStep, setNifStep] = useState(true);
  const [nifInput, setNifInput] = useState("");
  const [checkingNif, setCheckingNif] = useState(false);
  const [previousSales, setPreviousSales] = useState([]);
  const [showSaleTypeDialog, setShowSaleTypeDialog] = useState(false);
  const [showAddressSelectionDialog, setShowAddressSelectionDialog] = useState(false);
  const [selectedSaleFlow, setSelectedSaleFlow] = useState(null);

  const [formData, setFormData] = useState({
    client_name: "",
    client_email: "",
    client_phone: "",
    client_nif: "",
    street_address: "",
    postal_code: "",
    city: "",
    category: "",
    sale_type: "",
    partner_id: "",
    operator_id: "",
    seller_id: "none",
    contract_value: "",
    loyalty_months: "",
    notes: "",
    energy_type: "",
    cpe: "",
    potencia: "",
    cui: "",
    escalao: "",
    services_tv: false,
    services_net: false,
    services_lr: false,
    services_moveis_count: 0
  });

  useEffect(() => {
    fetchPartners();
    fetchSellers();
    const refidFrom = searchParams.get('refid_from');
    if (refidFrom) {
      setNifStep(false);
      loadRefidData(refidFrom);
    }
  }, [searchParams]);

  const fetchPartners = async () => {
    try {
      const partnersData = await partnersService.getPartners();
      setPartners(partnersData);
    } catch (error) {
      console.error("Error fetching partners:", error);
      toast.error("Erro ao carregar parceiros");
    } finally {
      setLoadingPartners(false);
    }
  };

  const fetchSellers = async () => {
    try {
      const sellersData = await usersService.getUsersByRole("vendedor");
      setSellers(sellersData);
    } catch (error) {
      console.error("Error fetching sellers:", error);
    }
  };

  const fetchOperators = async (partnerId) => {
    if (!partnerId) {
      setOperators([]);
      return;
    }
    setLoadingOperators(true);
    try {
      const operatorsData = await operatorsService.getOperatorsByPartner(partnerId);
      setOperators(operatorsData);
    } catch (error) {
      console.error("Error fetching operators:", error);
      toast.error("Erro ao carregar operadoras");
    } finally {
      setLoadingOperators(false);
    }
  };

  const getFilteredOperators = () => {
    if (!formData.category) return operators;

    const requiredCategories = [];

    if (formData.category === 'energia') {
      if (formData.energy_type === 'eletricidade') {
        requiredCategories.push('energia_eletricidade');
      } else if (formData.energy_type === 'gas') {
        requiredCategories.push('energia_gas');
      } else if (formData.energy_type === 'dual') {
        requiredCategories.push('energia_eletricidade', 'energia_gas');
      }
    } else if (formData.category === 'telecomunicacoes') {
      requiredCategories.push('telecomunicacoes');
    } else if (formData.category === 'paineis_solares') {
      requiredCategories.push('paineis_solares');
    }

    if (requiredCategories.length === 0) return [];

    const filtered = operators.filter(op => {
      if (!op.categories || op.categories.length === 0) return false;

      if (formData.category === 'energia' && formData.energy_type === 'dual') {
        return requiredCategories.every(cat => op.categories.includes(cat));
      }

      return requiredCategories.some(cat => op.categories.includes(cat));
    });

    return filtered;
  };

  useEffect(() => {
    if (formData.partner_id) {
      fetchOperators(formData.partner_id);
    } else {
      setOperators([]);
      handleChange("operator_id", "");
    }
  }, [formData.partner_id]);

  useEffect(() => {
    const filtered = getFilteredOperators();
    const currentOperatorStillValid = filtered.some(op => op.id === formData.operator_id);
    if (!currentOperatorStillValid && formData.operator_id) {
      handleChange("operator_id", "");
    }
  }, [formData.category, formData.energy_type]);

  const loadRefidData = async (saleId) => {
    setLoadingRefidData(true);
    try {
      const originalSale = await salesService.getSaleById(saleId);

      const addressData = {
        street_address: originalSale.street_address || "",
        postal_code: originalSale.postal_code || "",
        city: originalSale.city || ""
      };

      setOriginalAddress(addressData);

      setFormData(prev => ({
        ...prev,
        client_name: originalSale.client_name || "",
        client_email: originalSale.client_email || "",
        client_phone: originalSale.client_phone || "",
        client_nif: originalSale.client_nif || "",
        ...addressData,
        category: originalSale.category || "",
        sale_type: "refid",
        partner_id: originalSale.partner_id || "",
        operator_id: originalSale.operator_id || "",
        loyalty_months: originalSale.loyalty_months?.toString() || "",
        energy_type: originalSale.energy_type || "",
        cpe: originalSale.cpe || "",
        potencia: originalSale.potencia || "",
        cui: originalSale.cui || "",
        escalao: originalSale.escalao || ""
      }));
      toast.success("Dados carregados para venda Refid");
    } catch (error) {
      console.error("Error loading refid data:", error);
      toast.error("Erro ao carregar dados da venda original");
    } finally {
      setLoadingRefidData(false);
    }
  };

  const handleChange = (field, value) => {
    setFormData(prev => ({ ...prev, [field]: value }));
  };

  const handleNifCheck = async () => {
    if (!nifInput) {
      toast.error("Insira um NIF");
      return;
    }

    if (nifInput.length !== 9 || !/^\d+$/.test(nifInput)) {
      toast.error("O NIF deve ter 9 dígitos numéricos");
      return;
    }

    setCheckingNif(true);
    try {
      const sales = await salesService.getSalesByNif(nifInput);

      if (sales && sales.length > 0) {
        setPreviousSales(sales);
        setShowSaleTypeDialog(true);
      } else {
        setFormData(prev => ({ ...prev, client_nif: nifInput }));
        setNifStep(false);
        toast.info("Novo cliente - preencha todos os dados");
      }
    } catch (error) {
      console.error("Error checking NIF:", error);
      toast.error("Erro ao verificar NIF");
    } finally {
      setCheckingNif(false);
    }
  };

  const handleNewSale = () => {
    const latestSale = previousSales[0];

    setFormData(prev => ({
      ...prev,
      client_nif: nifInput,
      client_name: latestSale.client_name || "",
      client_email: latestSale.client_email || "",
      client_phone: latestSale.client_phone || "",
      street_address: "",
      postal_code: "",
      city: ""
    }));

    setShowSaleTypeDialog(false);
    setNifStep(false);
    toast.info("Preencha os dados da nova venda");
  };

  const handleMudancaCasaFlow = () => {
    setSelectedSaleFlow('mudanca_casa');
    setShowSaleTypeDialog(false);
    setShowAddressSelectionDialog(true);
  };

  const handleRefidFlow = () => {
    setSelectedSaleFlow('refid');
    setShowSaleTypeDialog(false);
    setShowAddressSelectionDialog(true);
  };

  const handleAddressSelection = async (selectedSale) => {
    try {
      await salesService.cancelSaleLoyaltyAlerts(selectedSale.id);

      const isMudancaCasa = selectedSaleFlow === 'mudanca_casa';
      const saleType = isMudancaCasa ? 'mudanca_casa' : 'refid';

      const operatorAllowsSaleType = selectedSale.operators?.allowed_sale_types?.includes(saleType);

      if (!operatorAllowsSaleType && selectedSale.operators) {
        toast.warning(`A operadora ${selectedSale.operators.name} não permite vendas do tipo ${isMudancaCasa ? 'Mudança de Casa' : 'Refid'}`);
      }

      const validSeller = selectedSale.sellers?.active ? selectedSale.seller_id : "none";

      setFormData(prev => ({
        ...prev,
        client_nif: nifInput,
        client_name: selectedSale.client_name || "",
        client_email: selectedSale.client_email || "",
        client_phone: selectedSale.client_phone || "",
        street_address: isMudancaCasa ? "" : (selectedSale.street_address || ""),
        postal_code: isMudancaCasa ? "" : (selectedSale.postal_code || ""),
        city: isMudancaCasa ? "" : (selectedSale.city || ""),
        category: selectedSale.category || "",
        sale_type: operatorAllowsSaleType ? saleType : "",
        partner_id: selectedSale.partner_id || "",
        operator_id: selectedSale.operator_id || "",
        seller_id: validSeller,
        loyalty_months: selectedSale.loyalty_months?.toString() || "",
        energy_type: selectedSale.energy_type || "",
        cpe: selectedSale.cpe || "",
        potencia: selectedSale.potencia || "",
        cui: selectedSale.cui || "",
        escalao: selectedSale.escalao || ""
      }));

      if (isMudancaCasa) {
        setOriginalAddress({
          street_address: selectedSale.street_address || "",
          postal_code: selectedSale.postal_code || "",
          city: selectedSale.city || ""
        });
      }

      setShowAddressSelectionDialog(false);
      setNifStep(false);

      const flowName = isMudancaCasa ? "Mudança de Casa" : "Refid";
      toast.success(`Dados carregados para ${flowName}`);
    } catch (error) {
      console.error("Error loading sale data:", error);
      toast.error("Erro ao carregar dados da venda");
    }
  };

  const checkAddressChange = () => {
    if (!originalAddress) return false;

    return (
      formData.street_address !== originalAddress.street_address ||
      formData.postal_code !== originalAddress.postal_code ||
      formData.city !== originalAddress.city
    );
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    // Check if address changed and sale type is still refid
    if (formData.sale_type === "refid" && originalAddress && checkAddressChange()) {
      setShowAddressChangeDialog(true);
      return;
    }

    await submitSale();
  };

  const submitSale = async () => {
    // Validation
    if (!formData.client_name || !formData.category || !formData.partner_id) {
      toast.error("Preencha os campos obrigatórios (Nome, Categoria, Parceiro)");
      return;
    }

    if (!formData.operator_id) {
      toast.error("Selecione uma operadora");
      return;
    }

    if (!formData.client_phone && !formData.client_email) {
      toast.error("Preencha pelo menos um contacto (telefone ou email)");
      return;
    }

    if (!formData.client_nif) {
      toast.error("O NIF é obrigatório");
      return;
    }

    if (formData.client_nif.length !== 9 || !/^\d+$/.test(formData.client_nif)) {
      toast.error("O NIF deve ter 9 dígitos numéricos");
      return;
    }

    if (!formData.street_address || !formData.postal_code || !formData.city) {
      toast.error("Todos os campos de morada são obrigatórios (Rua, Código Postal, Localidade)");
      return;
    }

    if (!/^\d{4}-\d{3}$/.test(formData.postal_code)) {
      toast.error("Código postal deve estar no formato 0000-000");
      return;
    }

    // Energy validation
    if (formData.category === "energia") {
      if (!formData.energy_type) {
        toast.error("Selecione o tipo de energia");
        return;
      }

      if ((formData.energy_type === "eletricidade" || formData.energy_type === "dual") && (!formData.cpe || !formData.potencia)) {
        toast.error("CPE e Potência são obrigatórios para eletricidade");
        return;
      }

      if ((formData.energy_type === "gas" || formData.energy_type === "dual") && (!formData.cui || !formData.escalao)) {
        toast.error("CUI e Escalão são obrigatórios para gás");
        return;
      }
    }

    setLoading(true);

    try {
      const payload = {
        ...formData,
        seller_id: formData.seller_id === "none" ? null : formData.seller_id,
        status: 'em_negociacao',
        contract_value: parseFloat(formData.contract_value) || 0,
        loyalty_months: parseInt(formData.loyalty_months) || 0,
        sale_type: formData.sale_type || null,
        energy_type: formData.energy_type || null,
        cpe: formData.cpe || null,
        potencia: formData.potencia || null,
        cui: formData.cui || null,
        escalao: formData.escalao || null,
        services_tv: formData.services_tv,
        services_net: formData.services_net,
        services_lr: formData.services_lr,
        services_moveis_count: parseInt(formData.services_moveis_count) || 0
      };

      await salesService.createSale(payload);
      toast.success("Venda criada com sucesso");
      navigate("/sales");
    } catch (error) {
      const message = error.message || "Erro ao guardar venda";
      toast.error(message);
    } finally {
      setLoading(false);
    }
  };

  // Show sale_type only for energia and telecomunicacoes
  const showSaleType = formData.category === "energia" || formData.category === "telecomunicacoes";
  
  // Energy fields
  const showEnergyFields = formData.category === "energia";
  const showElectricityFields = formData.energy_type === "eletricidade" || formData.energy_type === "dual";
  const showGasFields = formData.energy_type === "gas" || formData.energy_type === "dual";

  if (loadingPartners) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="spinner"></div>
      </div>
    );
  }

  if (partners.length === 0) {
    return (
      <div className="max-w-3xl mx-auto">
        <Card className="card-leiritrix">
          <CardContent className="p-8 text-center">
            <p className="text-white/70 mb-4">Não existem parceiros registados.</p>
            <p className="text-white/50 text-sm mb-6">É necessário criar pelo menos um parceiro antes de registar vendas.</p>
            <Button
              onClick={() => navigate("/partners")}
              className="btn-primary btn-primary-glow"
            >
              Criar Parceiro
            </Button>
          </CardContent>
        </Card>
      </div>
    );
  }

  return (
    <div className="max-w-3xl mx-auto space-y-6" data-testid="sale-form-page">
      {/* Header */}
      <div className="flex items-center gap-4">
        <Button
          variant="ghost"
          onClick={() => navigate(-1)}
          className="text-white/70 hover:text-white"
          data-testid="back-btn"
        >
          <ArrowLeft size={20} />
        </Button>
        <div>
          <h1 className="text-2xl font-bold text-white font-['Manrope']">Nova Venda</h1>
          <p className="text-white/50 text-sm mt-1">
            {nifStep ? "Insira o NIF do cliente para começar" : "Preencha os dados para registar uma nova venda"}
          </p>
        </div>
      </div>

      {/* NIF Step */}
      {nifStep && (
        <Card className="card-leiritrix">
          <CardContent className="p-8">
            <div className="text-center space-y-6">
              <div className="w-16 h-16 rounded-full bg-[#c8f31d]/20 flex items-center justify-center mx-auto">
                <User size={32} className="text-[#c8f31d]" />
              </div>
              <div>
                <h2 className="text-xl font-bold text-white mb-2">NIF do Cliente</h2>
                <p className="text-white/60 text-sm">
                  Insira o NIF para verificar se o cliente já tem vendas registadas
                </p>
              </div>
              <div className="max-w-md mx-auto">
                <Input
                  value={nifInput}
                  onChange={(e) => setNifInput(e.target.value)}
                  onKeyPress={(e) => {
                    if (e.key === 'Enter' && !checkingNif) {
                      handleNifCheck();
                    }
                  }}
                  className="form-input text-center text-lg"
                  placeholder="123456789"
                  maxLength={9}
                  autoFocus
                  data-testid="nif-input"
                />
              </div>
              <Button
                onClick={handleNifCheck}
                disabled={checkingNif || !nifInput}
                className="btn-primary btn-primary-glow"
                data-testid="check-nif-btn"
              >
                {checkingNif ? (
                  <>
                    <Loader2 size={18} className="mr-2 animate-spin" />
                    A verificar...
                  </>
                ) : (
                  <>
                    IR
                    <ArrowRight size={18} className="ml-2" />
                  </>
                )}
              </Button>
            </div>
          </CardContent>
        </Card>
      )}

      {/* Form */}
      {!nifStep && (
        <form onSubmit={handleSubmit} data-testid="sale-form">
          {/* Client Data */}
          <Card className="card-leiritrix">
          <CardHeader className="border-b border-white/5 pb-4">
            <CardTitle className="text-white font-['Manrope'] text-lg flex items-center gap-2">
              <User size={20} className="text-[#c8f31d]" />
              Dados do Cliente
            </CardTitle>
          </CardHeader>
          <CardContent className="pt-6 space-y-6">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div>
                <Label htmlFor="client_name" className="form-label">Nome do Cliente *</Label>
                <Input
                  id="client_name"
                  value={formData.client_name}
                  onChange={(e) => handleChange("client_name", e.target.value)}
                  className="form-input"
                  placeholder="Nome completo"
                  data-testid="client-name-input"
                />
              </div>
              
              <div>
                <Label htmlFor="client_nif" className="form-label">NIF *</Label>
                <Input
                  id="client_nif"
                  value={formData.client_nif}
                  onChange={(e) => handleChange("client_nif", e.target.value)}
                  className="form-input"
                  placeholder="123456789"
                  maxLength={9}
                  data-testid="client-nif-input"
                />
              </div>

              <div>
                <Label htmlFor="client_email" className="form-label">Email *</Label>
                <Input
                  id="client_email"
                  type="email"
                  value={formData.client_email}
                  onChange={(e) => handleChange("client_email", e.target.value)}
                  className="form-input"
                  placeholder="cliente@email.pt"
                  data-testid="client-email-input"
                />
              </div>

              <div>
                <Label htmlFor="client_phone" className="form-label">Telefone *</Label>
                <Input
                  id="client_phone"
                  value={formData.client_phone}
                  onChange={(e) => handleChange("client_phone", e.target.value)}
                  className="form-input"
                  placeholder="912 345 678"
                  data-testid="client-phone-input"
                />
              </div>

              <div className="md:col-span-2">
                <Label htmlFor="street_address" className="form-label">Rua e Número *</Label>
                <Input
                  id="street_address"
                  value={formData.street_address}
                  onChange={(e) => handleChange("street_address", e.target.value)}
                  className="form-input"
                  placeholder="Rua das Flores, nº 123, 2º Esq"
                  data-testid="street-address-input"
                />
              </div>

              <div>
                <Label htmlFor="postal_code" className="form-label">Código Postal *</Label>
                <Input
                  id="postal_code"
                  value={formData.postal_code}
                  onChange={(e) => handleChange("postal_code", e.target.value)}
                  className="form-input"
                  placeholder="1000-100"
                  maxLength={8}
                  data-testid="postal-code-input"
                />
              </div>

              <div>
                <Label htmlFor="city" className="form-label">Localidade *</Label>
                <Input
                  id="city"
                  value={formData.city}
                  onChange={(e) => handleChange("city", e.target.value)}
                  className="form-input"
                  placeholder="Lisboa"
                  data-testid="city-input"
                />
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Contract Data */}
        <Card className="card-leiritrix mt-6">
          <CardHeader className="border-b border-white/5 pb-4">
            <CardTitle className="text-white font-['Manrope'] text-lg flex items-center gap-2">
              <FileText size={20} className="text-[#c8f31d]" />
              Dados do Contrato
            </CardTitle>
          </CardHeader>
          <CardContent className="pt-6 space-y-6">
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              <div className="md:col-span-2">
                <Label htmlFor="category" className="form-label">Categoria *</Label>
                <Select
                  value={formData.category}
                  onValueChange={(v) => {
                    handleChange("category", v);
                    if (v === "paineis_solares") {
                      handleChange("sale_type", "");
                      handleChange("energy_type", "");
                    }
                    if (v !== "energia") {
                      handleChange("energy_type", "");
                      handleChange("cpe", "");
                      handleChange("potencia", "");
                      handleChange("cui", "");
                      handleChange("escalao", "");
                    }
                  }}
                >
                  <SelectTrigger className="form-input" data-testid="category-select">
                    <SelectValue placeholder="Selecione a categoria" />
                  </SelectTrigger>
                  <SelectContent className="bg-[#082d32] border-white/10">
                    {CATEGORIES.map((cat) => (
                      <SelectItem key={cat.value} value={cat.value} className="text-white hover:bg-white/10">
                        {cat.label}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>

              {/* Energy Type - show immediately after selecting Energia */}
              {showEnergyFields && (
                <div className="md:col-span-2 p-4 bg-[#c8f31d]/5 border border-[#c8f31d]/20 rounded-lg">
                  <Label htmlFor="energy_type" className="form-label flex items-center gap-2">
                    <Zap size={16} className="text-[#c8f31d]" />
                    Tipo de Energia * (selecione para ver as operadoras disponíveis)
                  </Label>
                  <Select value={formData.energy_type} onValueChange={(v) => handleChange("energy_type", v)}>
                    <SelectTrigger className="form-input mt-2" data-testid="energy-type-select">
                      <SelectValue placeholder="Selecione o tipo de energia" />
                    </SelectTrigger>
                    <SelectContent className="bg-[#082d32] border-white/10">
                      {ENERGY_TYPES.map((type) => (
                        <SelectItem key={type.value} value={type.value} className="text-white hover:bg-white/10">
                          {type.label}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>
              )}

              {showSaleType && (
                <div>
                  <Label htmlFor="sale_type" className="form-label">Tipo de Venda</Label>
                  <Select value={formData.sale_type} onValueChange={(v) => handleChange("sale_type", v)}>
                    <SelectTrigger className="form-input" data-testid="sale-type-select">
                      <SelectValue placeholder="Selecione o tipo" />
                    </SelectTrigger>
                    <SelectContent className="bg-[#082d32] border-white/10">
                      {SALE_TYPES.map((type) => (
                        <SelectItem key={type.value} value={type.value} className="text-white hover:bg-white/10">
                          {type.label}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>
              )}

              <div>
                <Label htmlFor="partner_id" className="form-label">Parceiro *</Label>
                <Select value={formData.partner_id} onValueChange={(v) => handleChange("partner_id", v)}>
                  <SelectTrigger className="form-input" data-testid="partner-select">
                    <SelectValue placeholder="Selecione o parceiro" />
                  </SelectTrigger>
                  <SelectContent className="bg-[#082d32] border-white/10">
                    {partners.map((partner) => (
                      <SelectItem key={partner.id} value={partner.id} className="text-white hover:bg-white/10">
                        {partner.name}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>

              <div>
                <Label htmlFor="operator_id" className="form-label">Operadora *</Label>
                <Select
                  value={formData.operator_id}
                  onValueChange={(v) => handleChange("operator_id", v)}
                  disabled={!formData.partner_id || loadingOperators || !formData.category || (formData.category === 'energia' && !formData.energy_type)}
                >
                  <SelectTrigger className="form-input" data-testid="operator-select">
                    <SelectValue placeholder={
                      !formData.partner_id
                        ? "Selecione primeiro um parceiro"
                        : !formData.category
                        ? "Selecione primeiro a categoria"
                        : (formData.category === 'energia' && !formData.energy_type)
                        ? "↑ Selecione o tipo de energia acima"
                        : loadingOperators
                        ? "A carregar operadoras..."
                        : getFilteredOperators().length === 0
                        ? "Sem operadoras disponíveis"
                        : "Selecione a operadora"
                    } />
                  </SelectTrigger>
                  <SelectContent className="bg-[#082d32] border-white/10">
                    {getFilteredOperators().map((operator) => (
                      <SelectItem key={operator.id} value={operator.id} className="text-white hover:bg-white/10">
                        {operator.name}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
                {formData.partner_id && formData.category && (formData.category !== 'energia' || formData.energy_type) && getFilteredOperators().length === 0 && !loadingOperators && (
                  <p className="text-orange-400 text-xs mt-1">
                    Este parceiro não tem operadoras para esta categoria. Adicione uma operadora na página de Operadoras.
                  </p>
                )}
              </div>

              <div>
                <Label htmlFor="seller_id" className="form-label">Vendedor</Label>
                <Select value={formData.seller_id} onValueChange={(v) => handleChange("seller_id", v)}>
                  <SelectTrigger className="form-input" data-testid="seller-select">
                    <SelectValue placeholder="Selecione o vendedor" />
                  </SelectTrigger>
                  <SelectContent className="bg-[#082d32] border-white/10">
                    <SelectItem value="none" className="text-white hover:bg-white/10">
                      Nenhum
                    </SelectItem>
                    {sellers.map((seller) => (
                      <SelectItem key={seller.id} value={seller.id} className="text-white hover:bg-white/10">
                        {seller.name}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>

              {/* Mensalidade Contratada - apenas para Telecomunicações */}
              {formData.category === "telecomunicacoes" && (
                <div>
                  <Label htmlFor="contract_value" className="form-label">Mensalidade Contratada (€)</Label>
                  <Input
                    id="contract_value"
                    type="number"
                    step="0.01"
                    min="0"
                    value={formData.contract_value}
                    onChange={(e) => handleChange("contract_value", e.target.value)}
                    className="form-input"
                    placeholder="0.00"
                    data-testid="contract-value-input"
                  />
                </div>
              )}

              <div>
                <Label htmlFor="loyalty_months" className="form-label">Prazo de Fidelização (meses)</Label>
                <Input
                  id="loyalty_months"
                  type="number"
                  min="0"
                  value={formData.loyalty_months}
                  onChange={(e) => handleChange("loyalty_months", e.target.value)}
                  className="form-input"
                  placeholder="24"
                  data-testid="loyalty-months-input"
                />
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Energy Specific Fields */}
        {showEnergyFields && formData.energy_type && (
          <Card className="card-leiritrix mt-6">
            <CardHeader className="border-b border-white/5 pb-4">
              <CardTitle className="text-white font-['Manrope'] text-lg flex items-center gap-2">
                <Zap size={20} className="text-[#c8f31d]" />
                Detalhes de Energia ({ENERGY_TYPE_MAP[formData.energy_type]})
              </CardTitle>
            </CardHeader>
            <CardContent className="pt-6 space-y-6">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                {/* Electricity fields */}
                {showElectricityFields && (
                  <>
                    <div>
                      <Label htmlFor="cpe" className="form-label">CPE *</Label>
                      <Input
                        id="cpe"
                        value={formData.cpe}
                        onChange={(e) => handleChange("cpe", e.target.value)}
                        className="form-input"
                        placeholder="PT0002..."
                        data-testid="cpe-input"
                      />
                    </div>
                    <div>
                      <Label htmlFor="potencia" className="form-label">Potência (kVA) *</Label>
                      <Select value={formData.potencia} onValueChange={(v) => handleChange("potencia", v)}>
                        <SelectTrigger className="form-input" data-testid="potencia-select">
                          <SelectValue placeholder="Selecione a potência" />
                        </SelectTrigger>
                        <SelectContent className="bg-[#082d32] border-white/10 max-h-60">
                          {POTENCIAS.map((pot) => (
                            <SelectItem key={pot} value={pot} className="text-white hover:bg-white/10">
                              {pot} {pot !== "Outra" && "kVA"}
                            </SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                    </div>
                  </>
                )}

                {/* Gas fields */}
                {showGasFields && (
                  <>
                    <div>
                      <Label htmlFor="cui" className="form-label">CUI *</Label>
                      <Input
                        id="cui"
                        value={formData.cui}
                        onChange={(e) => handleChange("cui", e.target.value)}
                        className="form-input"
                        placeholder="CUI do ponto de entrega"
                        data-testid="cui-input"
                      />
                    </div>
                    <div>
                      <Label htmlFor="escalao" className="form-label">Escalão *</Label>
                      <Select value={formData.escalao} onValueChange={(v) => handleChange("escalao", v)}>
                        <SelectTrigger className="form-input" data-testid="escalao-select">
                          <SelectValue placeholder="Selecione o escalão" />
                        </SelectTrigger>
                        <SelectContent className="bg-[#082d32] border-white/10">
                          {ESCALOES_GAS.map((esc) => (
                            <SelectItem key={esc} value={esc} className="text-white hover:bg-white/10">
                              {esc}
                            </SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                    </div>
                  </>
                )}
              </div>
            </CardContent>
          </Card>
        )}

        {/* Services - only for telecomunicacoes NI and MC */}
        {formData.category === "telecomunicacoes" && (formData.sale_type === "nova_instalacao" || formData.sale_type === "mudanca_casa") && (
          <Card className="card-leiritrix mt-6">
            <CardHeader className="border-b border-white/5 pb-4">
              <CardTitle className="text-white font-['Manrope'] text-lg flex items-center gap-2">
                <PhoneIcon size={20} className="text-[#c8f31d]" />
                Serviços a Ativar
              </CardTitle>
            </CardHeader>
            <CardContent className="pt-6 space-y-6">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div className="flex items-center space-x-3">
                  <Checkbox
                    id="services_tv"
                    checked={formData.services_tv}
                    onCheckedChange={(checked) => handleChange("services_tv", checked)}
                    className="border-white/20"
                    data-testid="services-tv-checkbox"
                  />
                  <Label htmlFor="services_tv" className="form-label cursor-pointer">TV</Label>
                </div>

                <div className="flex items-center space-x-3">
                  <Checkbox
                    id="services_net"
                    checked={formData.services_net}
                    onCheckedChange={(checked) => handleChange("services_net", checked)}
                    className="border-white/20"
                    data-testid="services-net-checkbox"
                  />
                  <Label htmlFor="services_net" className="form-label cursor-pointer">NET (Internet)</Label>
                </div>

                <div className="flex items-center space-x-3">
                  <Checkbox
                    id="services_lr"
                    checked={formData.services_lr}
                    onCheckedChange={(checked) => handleChange("services_lr", checked)}
                    className="border-white/20"
                    data-testid="services-lr-checkbox"
                  />
                  <Label htmlFor="services_lr" className="form-label cursor-pointer">LR (Linha Rede)</Label>
                </div>

                <div>
                  <Label htmlFor="services_moveis_count" className="form-label">Móveis (máximo 5)</Label>
                  <Input
                    id="services_moveis_count"
                    type="number"
                    min="0"
                    max="5"
                    value={formData.services_moveis_count}
                    onChange={(e) => {
                      const val = parseInt(e.target.value) || 0;
                      handleChange("services_moveis_count", Math.min(5, Math.max(0, val)));
                    }}
                    className="form-input"
                    placeholder="0"
                    data-testid="services-moveis-input"
                  />
                </div>
              </div>
            </CardContent>
          </Card>
        )}

        {/* Notes */}
        <Card className="card-leiritrix mt-6">
          <CardContent className="pt-6">
            <Label htmlFor="notes" className="form-label">Notas</Label>
            <Textarea
              id="notes"
              value={formData.notes}
              onChange={(e) => handleChange("notes", e.target.value)}
              className="form-input min-h-24"
              placeholder="Observações adicionais..."
              data-testid="notes-input"
            />
          </CardContent>
        </Card>

        {/* Actions */}
        <div className="flex justify-end gap-4 mt-6">
          <Button
            type="button"
            variant="ghost"
            onClick={() => navigate(-1)}
            className="btn-secondary"
            data-testid="cancel-btn"
          >
            Cancelar
          </Button>
          <Button
            type="submit"
            disabled={loading}
            className="btn-primary btn-primary-glow"
            data-testid="submit-btn"
          >
            {loading ? (
              <>
                <Loader2 size={18} className="mr-2 animate-spin" />
                A guardar...
              </>
            ) : (
              <>
                <Save size={18} className="mr-2" />
                Criar Venda
              </>
            )}
          </Button>
        </div>
      </form>
      )}

      {/* Sale Type Selection Dialog */}
      <AlertDialog open={showSaleTypeDialog} onOpenChange={setShowSaleTypeDialog}>
        <AlertDialogContent className="bg-[#082d32] border-[#c8f31d]/30 max-w-md">
          <AlertDialogHeader>
            <AlertDialogTitle className="text-white">Cliente Existente</AlertDialogTitle>
            <AlertDialogDescription className="text-white/70">
              Encontrámos {previousSales.length} venda(s) para este NIF. Que tipo de venda pretende registar?
            </AlertDialogDescription>
          </AlertDialogHeader>
          <div className="space-y-3 py-4">
            <Button
              onClick={handleNewSale}
              className="w-full bg-green-600 hover:bg-green-700 text-white justify-start"
              data-testid="new-sale-btn"
            >
              <Plus size={18} className="mr-2" />
              <div className="text-left">
                <div className="font-semibold">Nova Venda</div>
                <div className="text-xs opacity-80">Nova morada e contrato</div>
              </div>
            </Button>
            <Button
              onClick={handleMudancaCasaFlow}
              className="w-full bg-[#c8f31d] hover:bg-[#d4ff3d] text-[#0d474f] justify-start"
              data-testid="mc-flow-btn"
            >
              <Home size={18} className="mr-2" />
              <div className="text-left">
                <div className="font-semibold">Mudança de Casa (MC)</div>
                <div className="text-xs opacity-80">Cliente muda de morada</div>
              </div>
            </Button>
            <Button
              onClick={handleRefidFlow}
              className="w-full bg-blue-600 hover:bg-blue-700 text-white justify-start"
              data-testid="refid-flow-btn"
            >
              <FileText size={18} className="mr-2" />
              <div className="text-left">
                <div className="font-semibold">Refid (Renovação)</div>
                <div className="text-xs opacity-80">Renovação na mesma morada</div>
              </div>
            </Button>
          </div>
          <AlertDialogFooter>
            <AlertDialogCancel
              className="bg-white/10 text-white hover:bg-white/20"
              onClick={() => {
                setShowSaleTypeDialog(false);
                setPreviousSales([]);
              }}
            >
              Cancelar
            </AlertDialogCancel>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>

      {/* Address Selection Dialog */}
      <AlertDialog open={showAddressSelectionDialog} onOpenChange={setShowAddressSelectionDialog}>
        <AlertDialogContent className="bg-[#082d32] border-[#c8f31d]/30 max-w-2xl">
          <AlertDialogHeader>
            <AlertDialogTitle className="text-white">
              Selecione a Morada {selectedSaleFlow === 'mudanca_casa' ? 'Original' : 'para Renovação'}
            </AlertDialogTitle>
            <AlertDialogDescription className="text-white/70">
              {selectedSaleFlow === 'mudanca_casa'
                ? 'Qual a morada original do cliente antes da mudança?'
                : 'Qual a morada que pretende renovar?'
              }
            </AlertDialogDescription>
          </AlertDialogHeader>
          <div className="space-y-2 py-4 max-h-96 overflow-y-auto">
            {previousSales.map((sale) => (
              <Button
                key={sale.id}
                onClick={() => handleAddressSelection(sale)}
                className="w-full bg-[#0d474f] hover:bg-[#0d474f]/80 text-white justify-start p-4 h-auto"
                data-testid={`address-option-${sale.id}`}
              >
                <div className="flex-1 text-left">
                  <div className="font-semibold">{sale.street_address}</div>
                  <div className="text-sm opacity-80">{sale.postal_code} {sale.city}</div>
                  <div className="text-xs opacity-60 mt-1">
                    {sale.operators?.name} • {sale.category === 'energia' ? 'Energia' : sale.category === 'telecomunicacoes' ? 'Telecomunicações' : 'Painéis Solares'}
                    {sale.loyalty_months > 0 && ` • ${sale.loyalty_months} meses fidelização`}
                  </div>
                </div>
              </Button>
            ))}
          </div>
          <AlertDialogFooter>
            <AlertDialogCancel
              className="bg-white/10 text-white hover:bg-white/20"
              onClick={() => {
                setShowAddressSelectionDialog(false);
                setShowSaleTypeDialog(true);
              }}
            >
              Voltar
            </AlertDialogCancel>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>

      {/* Address Change Dialog */}
      <AlertDialog open={showAddressChangeDialog} onOpenChange={setShowAddressChangeDialog}>
        <AlertDialogContent className="bg-[#082d32] border-[#c8f31d]/30">
          <AlertDialogHeader>
            <AlertDialogTitle className="text-white">Mudança de Morada Detectada</AlertDialogTitle>
            <AlertDialogDescription className="text-white/70">
              A morada foi alterada em relação à venda original. Este contrato é:
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel
              className="bg-white/10 text-white hover:bg-white/20"
              onClick={() => setShowAddressChangeDialog(false)}
            >
              Cancelar
            </AlertDialogCancel>
            <AlertDialogAction
              className="bg-blue-600 text-white hover:bg-blue-700"
              onClick={() => {
                setShowAddressChangeDialog(false);
                submitSale();
              }}
            >
              Renovação (Refid) na mesma morada
            </AlertDialogAction>
            <AlertDialogAction
              className="bg-[#c8f31d] text-[#0d474f] hover:bg-[#d4ff3d]"
              onClick={() => {
                handleChange("sale_type", "mudanca_casa");
                setShowAddressChangeDialog(false);
                setTimeout(() => submitSale(), 100);
              }}
            >
              Mudança de Casa (MC)
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}
