import PageDashboard from '../components/dashboard/dashboard';
import Layout from '../components/Layout';
import 'bootstrap/dist/css/bootstrap.min.css';

export default function CrudPage() {
  return (
    <>
      <Layout>
      <div className="crud-container">
      <PageDashboard/>
      </div>
      </Layout>
    </>
  );
}