# Documentação complementar

- [README principal](../README.md)
- [Relatório acadêmico](../RELATORIO.md)
- [Comandos](../comandos.txt)
- [Evidências](../evidencias/MODELO-EVIDENCIAS.md)

## Diagrama de fluxo

```
Desenvolvedor
    │
    ├─► terraform apply ──► Azure (VM, Rede, NSG, IP)
    │
    ├─► ansible-playbook ──► IIS + Página MobEAD
    │
    └─► validate-iis.sh ──► HTTP 200 OK
```

## Custos estimados Azure

- VM Standard_B2s: ~USD 30-40/mês (se deixar ligada)
- **Importante:** execute `terraform destroy` após gerar evidências
