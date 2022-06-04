import '../styles/globals.css';
import { Toaster } from 'react-hot-toast';
//import { UserProvider } from '../UserProvider';
import { NhostNextProvider, NhostClient } from '@nhost/nextjs';
import { NhostApolloProvider } from '@nhost/react-apollo'

const nhost = new NhostClient({
  backendUrl: process.env.NEXT_PUBLIC_NHOST_BACKEND_URL || '',
});

function MyApp({ Component, pageProps }) {
  return (
    <NhostNextProvider nhost={nhost} initial={pageProps.nhostSession}>
      <NhostApolloProvider nhost={nhost}>
        <Component {...pageProps} />
        <Toaster />
      </NhostApolloProvider>
    </NhostNextProvider>
  );
}

export default MyApp;
