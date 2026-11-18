
import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // 1. Verificar que exista una sesión autenticada.
    const authHeader = req.headers.get("Authorization");

    if (!authHeader?.startsWith("Bearer ")) {
      return Response.json(
        { error: "Usuario no autenticado" },
        { status: 401, headers: corsHeaders },
      );
    }

    const token = authHeader.replace("Bearer ", "");

    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseKey =
      Deno.env.get("SUPABASE_ANON_KEY") ??
      Deno.env.get("SUPABASE_PUBLISHABLE_KEY");

    if (!supabaseKey) {
      throw new Error("No se encontró la clave pública de Supabase");
    }

    const supabase = createClient(supabaseUrl, supabaseKey, {
      global: {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      },
    });

    const { data: userData, error: authError } =
      await supabase.auth.getUser(token);

    if (authError || !userData.user) {
      return Response.json(
        { error: "Sesión inválida" },
        { status: 401, headers: corsHeaders },
      );
    }

    // 2. Comprobar que el usuario sea administrador del museo.
    const { data: perfil, error: perfilError } = await supabase
      .from("perfiles")
      .select("rol, estado")
      .eq("id_usuario", userData.user.id)
      .maybeSingle();

    if (
      perfilError ||
      !perfil ||
      perfil.rol !== "admin_museo" ||
      perfil.estado !== true
    ) {
      return Response.json(
        { error: "No tenés permisos para generar imágenes" },
        { status: 403, headers: corsHeaders },
      );
    }

    // 3. Validar descripción.
    const body = await req.json();
    const descripcion = body.descripcion;

    if (
      typeof descripcion !== "string" ||
      descripcion.trim().length < 3 ||
      descripcion.length > 500
    ) {
      return Response.json(
        { error: "La descripción debe tener entre 3 y 500 caracteres" },
        { status: 400, headers: corsHeaders },
      );
    }


// 4. Obtener la clave de OVHcloud.
const ovhKey = Deno.env.get("OVH_AI_ENDPOINTS_ACCESS_TOKEN");

if (!ovhKey) {
  throw new Error("No está configurada la clave de OVHcloud");
}

// 5. Solicitar la imagen a Stable Diffusion XL.
const imageResponse = await fetch(
  "https://oai.endpoints.kepler.ai.cloud.ovh.net/v1/images/generations",
  {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${ovhKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model: "stable-diffusion-xl-base-v10",
      prompt,
      size: "1024x1024",
      n: 1,
    }),
  },
);

if (!imageResponse.ok) {
  const errorData = await imageResponse.text();

  console.error("Error de OVHcloud:", errorData);

  return Response.json(
    { error: "No se pudo generar la imagen" },
    { status: 502, headers: corsHeaders },
  );
}

// 6. Obtener la imagen en Base64.
const imageData = await imageResponse.json();
const imageBase64 = imageData.data?.[0]?.b64_json;

if (!imageBase64) {
  throw new Error("OVHcloud no devolvió una imagen");
}

// 7. Devolver la imagen a Flutter.
return Response.json(
  {
    imageBase64,
    extension: "png",
  },
  { headers: corsHeaders },
);


    // 6. Solicitar la imagen a OpenAI.
    const openAiResponse = await fetch(
      "https://api.openai.com/v1/images/generations",
      {
        method: "POST",
        headers: {
          "Authorization": `Bearer ${openAiKey}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          model: "gpt-image-2.5-flare",
          prompt,
          size: "1024x1024",
          quality: "medium",
          background: "transparent",
          output_format: "png",
          n: 1,
        }),
      },
    );

    if (!openAiResponse.ok) {
      const errorData = await openAiResponse.text();
      console.error("Error de OpenAI:", errorData);

      return Response.json(
        { error: "No se pudo generar la imagen" },
        { status: 502, headers: corsHeaders },
      );
    }

    const imageData = await openAiResponse.json();
    const imageBase64 = imageData.data?.[0]?.b64_json;

    if (!imageBase64) {
      throw new Error("OpenAI no devolvió una imagen");
    }

    // 7. Devolver la imagen a Flutter.
    return Response.json(
      {
        imageBase64,
        extension: "png",
      },
      { headers: corsHeaders },
    );
  } catch (error) {
    console.error("Error en generar-insignia:", error);

    return Response.json(
      { error: "Ocurrió un error al generar la imagen" },
      { status: 500, headers: corsHeaders },
    );
  }
});
