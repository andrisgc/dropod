CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE IF NOT EXISTS eventos_externos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    provedor VARCHAR(50) NOT NULL,
    evento_id VARCHAR(255) NOT NULL,
    payload JSONB NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'RECEBIDO',
    criado_em TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_provedor_evento UNIQUE (provedor, evento_id)
);

CREATE INDEX IF NOT EXISTS idx_eventos_externos_status ON eventos_externos(status);
